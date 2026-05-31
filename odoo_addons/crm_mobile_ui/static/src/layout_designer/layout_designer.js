/** @odoo-module **/

import { registry } from "@web/core/registry";
import { useService } from "@web/core/utils/hooks";
import { Component, useState, onWillStart } from "@odoo/owl";

const DND_MIME = "application/x-mobile-ui-field";

export class LayoutDesigner extends Component {
    static template = "crm_mobile_ui.LayoutDesigner";
    static props = ["*"];

    setup() {
        this.orm = useService("orm");
        this.notification = useService("notification");
        this.action = useService("action");

        // Do NOT store drag-over in reactive state — re-renders cancel HTML5 drag.
        this._dndPayload = null;
        this._dragHighlightEl = null;

        this.state = useState({
            loading: true,
            saving: false,
            dirty: false,
            layout: null,
            sections: [],
            availableFields: [],
            widgetSelection: [],
            preview: null,
            paletteQuery: "",
            selected: null,
            includeCustomFields: false,
            otherInfoTitle: "",
        });

        onWillStart(async () => {
            const layoutId = this._layoutId();
            if (!layoutId) {
                this.notification.add("No layout selected.", { type: "danger" });
                return;
            }
            await this._load(layoutId);
        });
    }

    _layoutId() {
        return (
            this.props.action?.params?.layout_id ||
            this.props.action?.context?.active_id ||
            this.props.action?.context?.layout_id
        );
    }

    async _load(layoutId) {
        this.state.loading = true;
        try {
            const data = await this.orm.call(
                "mobile.ui.layout",
                "get_designer_data",
                [layoutId]
            );
            this._applyServerData(data);
            this.state.dirty = false;
        } catch (e) {
            this.notification.add(e.message || String(e), { type: "danger" });
        } finally {
            this.state.loading = false;
        }
    }

    _applyServerData(data) {
        this.state.layout = data.layout;
        this.state.sections = data.sections.map((s) => ({
            ...s,
            fields: s.fields.map((f) => ({ ...f })),
        }));
        this.state.availableFields = data.available_fields || [];
        this.state.widgetSelection = data.widget_selection || [];
        this.state.preview = data.preview;
        this.state.includeCustomFields = data.layout.include_custom_fields;
        this.state.otherInfoTitle = data.layout.other_info_title || "";
        this.state.selected = null;
    }

    get filteredPalette() {
        const q = (this.state.paletteQuery || "").trim().toLowerCase();
        if (!q) {
            return this.state.availableFields;
        }
        return this.state.availableFields.filter(
            (f) =>
                f.name.toLowerCase().includes(q) ||
                (f.string || "").toLowerCase().includes(q)
        );
    }

    get selectedField() {
        const sel = this.state.selected;
        if (!sel) {
            return null;
        }
        const section = this.state.sections[sel.sectionIndex];
        if (!section) {
            return null;
        }
        return section.fields[sel.fieldIndex] || null;
    }

    get isListScreen() {
        return this.state.layout?.screen === "list";
    }

    markDirty() {
        this.state.dirty = true;
    }

    _setDndPayload(payload) {
        this._dndPayload = payload;
    }

    _readDragPayload(ev) {
        if (this._dndPayload) {
            return this._dndPayload;
        }
        try {
            const raw =
                ev.dataTransfer.getData(DND_MIME) ||
                ev.dataTransfer.getData("text/plain");
            if (!raw) {
                return null;
            }
            if (raw.startsWith("{")) {
                return JSON.parse(raw);
            }
            const name = raw;
            const field = this.state.availableFields.find((f) => f.name === name);
            if (field) {
                return { source: "palette", field };
            }
        } catch {
            return null;
        }
        return null;
    }

    _clearDnd() {
        this._dndPayload = null;
        this._clearDropHighlight();
    }

    _setDropHighlight(el) {
        if (!el) {
            return;
        }
        if (this._dragHighlightEl && this._dragHighlightEl !== el) {
            this._dragHighlightEl.classList.remove("o_drop_target");
        }
        this._dragHighlightEl = el;
        el.classList.add("o_drop_target");
    }

    _clearDropHighlight() {
        if (this._dragHighlightEl) {
            this._dragHighlightEl.classList.remove("o_drop_target");
            this._dragHighlightEl = null;
        }
    }

    _allowDrop(ev) {
        ev.preventDefault();
        ev.stopPropagation();
        if (ev.dataTransfer) {
            ev.dataTransfer.dropEffect =
                this._dndPayload?.source === "palette" ? "copy" : "move";
        }
    }

    onPaletteQuery(ev) {
        this.state.paletteQuery = ev.target.value;
    }

    onPaletteDragStart(ev, field) {
        ev.stopPropagation();
        const payload = { source: "palette", field };
        this._setDndPayload(payload);
        const encoded = JSON.stringify(payload);
        ev.dataTransfer.setData(DND_MIME, encoded);
        ev.dataTransfer.setData("text/plain", encoded);
        ev.dataTransfer.effectAllowed = "copy";
    }

    onFieldDragStart(ev, sectionIndex, fieldIndex) {
        ev.stopPropagation();
        const payload = { source: "canvas", sectionIndex, fieldIndex };
        this._setDndPayload(payload);
        const encoded = JSON.stringify(payload);
        ev.dataTransfer.setData(DND_MIME, encoded);
        ev.dataTransfer.setData("text/plain", encoded);
        ev.dataTransfer.effectAllowed = "move";
    }

    onDragEnd() {
        this._clearDnd();
    }

    onDragOverFieldList(ev, sectionIndex) {
        this._allowDrop(ev);
        this._setDropHighlight(ev.currentTarget);
    }

    onDragOverFieldItem(ev, sectionIndex, fieldIndex) {
        this._allowDrop(ev);
        this._setDropHighlight(ev.currentTarget);
    }

    onDragOverDropZone(ev, sectionIndex) {
        this._allowDrop(ev);
        this._setDropHighlight(ev.currentTarget);
    }

    onDragLeaveDropTarget(ev) {
        const related = ev.relatedTarget;
        if (!related || !ev.currentTarget.contains(related)) {
            ev.currentTarget.classList.remove("o_drop_target");
            if (this._dragHighlightEl === ev.currentTarget) {
                this._dragHighlightEl = null;
            }
        }
    }

    onDropOnSection(ev, sectionIndex) {
        ev.preventDefault();
        ev.stopPropagation();
        const payload = this._readDragPayload(ev);
        this._clearDnd();
        if (!payload) {
            return;
        }
        if (payload.source === "palette") {
            this._addFieldFromPalette(sectionIndex, payload.field);
        } else if (payload.source === "canvas") {
            this._moveField(
                payload.sectionIndex,
                payload.fieldIndex,
                sectionIndex,
                null
            );
        }
        this.markDirty();
    }

    onDropOnField(ev, sectionIndex, fieldIndex) {
        ev.preventDefault();
        ev.stopPropagation();
        const payload = this._readDragPayload(ev);
        this._clearDnd();
        if (!payload) {
            return;
        }
        if (payload.source === "palette") {
            this._addFieldFromPalette(sectionIndex, payload.field, fieldIndex);
        } else if (payload.source === "canvas") {
            this._moveField(
                payload.sectionIndex,
                payload.fieldIndex,
                sectionIndex,
                fieldIndex
            );
        }
        this.markDirty();
    }

    _addFieldFromPalette(sectionIndex, paletteField, insertAt = null) {
        const section = this.state.sections[sectionIndex];
        if (!section) {
            return;
        }
        const exists = this.state.sections.some((s) =>
            s.fields.some((f) => f.field_name === paletteField.name)
        );
        if (exists) {
            this.notification.add(
                `Field "${paletteField.name}" is already on the layout.`,
                { type: "warning" }
            );
            return;
        }
        const newField = {
            id: null,
            field_name: paletteField.name,
            field_label: paletteField.string,
            field_type: paletteField.type,
            label: "",
            sequence: 10,
            widget: paletteField.suggested_widget || "text",
            readonly: false,
            required: false,
            show_if_empty: false,
            copyable: false,
            list_primary: false,
            list_subtitle: false,
        };
        if (insertAt === null || insertAt >= section.fields.length) {
            newField.sequence = (section.fields.length + 1) * 10;
            section.fields.push(newField);
        } else {
            section.fields.splice(insertAt, 0, newField);
            this._resequenceFields(section);
        }
        this.state.availableFields = this.state.availableFields.filter(
            (f) => f.name !== paletteField.name
        );
        this.state.selected = {
            sectionIndex,
            fieldIndex:
                insertAt === null ? section.fields.length - 1 : insertAt,
        };
    }

    _moveField(fromSectionIdx, fromFieldIdx, toSectionIdx, toFieldIdx) {
        const fromSection = this.state.sections[fromSectionIdx];
        const toSection = this.state.sections[toSectionIdx];
        if (!fromSection || !toSection) {
            return;
        }
        const [field] = fromSection.fields.splice(fromFieldIdx, 1);
        if (!field) {
            return;
        }
        let insertAt = toFieldIdx;
        if (fromSectionIdx === toSectionIdx && toFieldIdx !== null) {
            if (toFieldIdx > fromFieldIdx) {
                insertAt = toFieldIdx - 1;
            }
        }
        if (insertAt === null || insertAt >= toSection.fields.length) {
            toSection.fields.push(field);
        } else {
            toSection.fields.splice(insertAt, 0, field);
        }
        this._resequenceFields(fromSection);
        if (fromSection !== toSection) {
            this._resequenceFields(toSection);
        }
        const newIndex = toSection.fields.indexOf(field);
        this.state.selected = { sectionIndex: toSectionIdx, fieldIndex: newIndex };
    }

    _resequenceFields(section) {
        section.fields.forEach((f, i) => {
            f.sequence = (i + 1) * 10;
        });
    }

    selectField(sectionIndex, fieldIndex) {
        this.state.selected = { sectionIndex, fieldIndex };
    }

    addFieldFromPaletteClick(field) {
        if (!this.state.sections.length) {
            this.notification.add("Add a section first.", { type: "warning" });
            return;
        }
        this._addFieldFromPalette(0, field);
        this.markDirty();
    }

    removeSelectedField() {
        const sel = this.state.selected;
        if (!sel) {
            return;
        }
        const section = this.state.sections[sel.sectionIndex];
        const [removed] = section.fields.splice(sel.fieldIndex, 1);
        if (removed) {
            this.state.availableFields.push({
                name: removed.field_name,
                string: removed.field_label || removed.field_name,
                type: removed.field_type || "char",
                relation: false,
                suggested_widget: removed.widget,
            });
            this.state.availableFields.sort((a, b) =>
                (a.string || a.name).localeCompare(b.string || b.name)
            );
        }
        this._resequenceFields(section);
        this.state.selected = null;
        this.markDirty();
    }

    addSection() {
        const seq = (this.state.sections.length + 1) * 10;
        this.state.sections.push({
            id: null,
            name: `Section ${this.state.sections.length + 1}`,
            sequence: seq,
            collapsed: false,
            fields: [],
        });
        this.markDirty();
    }

    removeSection(sectionIndex) {
        const section = this.state.sections[sectionIndex];
        if (!section) {
            return;
        }
        for (const f of section.fields) {
            this.state.availableFields.push({
                name: f.field_name,
                string: f.field_label || f.field_name,
                type: f.field_type || "char",
                relation: false,
                suggested_widget: f.widget,
            });
        }
        this.state.availableFields.sort((a, b) =>
            (a.string || a.name).localeCompare(b.string || b.name)
        );
        this.state.sections.splice(sectionIndex, 1);
        this.state.selected = null;
        this.markDirty();
    }

    updateSectionName(sectionIndex, ev) {
        this.state.sections[sectionIndex].name = ev.target.value;
        this.markDirty();
    }

    toggleSectionCollapsed(sectionIndex, ev) {
        this.state.sections[sectionIndex].collapsed = ev.target.checked;
        this.markDirty();
    }

    updateSelected(prop, value) {
        const field = this.selectedField;
        if (!field) {
            return;
        }
        field[prop] = value;
        this.markDirty();
    }

    onPropInput(prop, ev) {
        this.updateSelected(prop, ev.target.value);
    }

    onPropCheck(prop, ev) {
        this.updateSelected(prop, ev.target.checked);
    }

    onLayoutCheck(prop, ev) {
        this.state[prop] = ev.target.checked;
        this.markDirty();
    }

    onOtherInfoTitle(ev) {
        this.state.otherInfoTitle = ev.target.value;
        this.markDirty();
    }

    isFieldSelected(sectionIndex, fieldIndex) {
        const sel = this.state.selected;
        return (
            sel &&
            sel.sectionIndex === sectionIndex &&
            sel.fieldIndex === fieldIndex
        );
    }

    async onSave() {
        if (!this.state.layout) {
            return;
        }
        this.state.saving = true;
        try {
            const payload = {
                include_custom_fields: this.state.includeCustomFields,
                other_info_title: this.state.otherInfoTitle,
                sections: this.state.sections.map((s, i) => ({
                    name: s.name,
                    sequence: (i + 1) * 10,
                    collapsed: s.collapsed,
                    fields: s.fields.map((f, j) => ({
                        field_name: f.field_name,
                        label: f.label || "",
                        sequence: (j + 1) * 10,
                        widget: f.widget,
                        readonly: f.readonly,
                        required: f.required,
                        show_if_empty: f.show_if_empty,
                        copyable: f.copyable,
                        list_primary: f.list_primary,
                        list_subtitle: f.list_subtitle,
                    })),
                })),
            };
            const result = await this.orm.call(
                "mobile.ui.layout",
                "save_designer_state",
                [this.state.layout.id, payload]
            );
            this.state.layout.version = result.version;
            this.state.preview = result.preview;
            this.state.dirty = false;
            await this._load(this.state.layout.id);
            this.notification.add("Layout saved.", { type: "success" });
        } catch (e) {
            this.notification.add(e.message || String(e), { type: "danger" });
        } finally {
            this.state.saving = false;
        }
    }

    async onBack() {
        if (this.state.dirty) {
            const ok = window.confirm(
                "You have unsaved changes. Leave without saving?"
            );
            if (!ok) {
                return;
            }
        }
        await this.action.doAction({
            type: "ir.actions.act_window",
            res_model: "mobile.ui.layout",
            res_id: this.state.layout?.id,
            views: [[false, "form"]],
            target: "current",
        });
    }
}

registry.category("actions").add("crm_mobile_ui.LayoutDesigner", LayoutDesigner);
