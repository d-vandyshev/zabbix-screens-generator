import {Controller} from 'stimulus'

export default class extends Controller {
    static targets = ["hostgroup_id", "submit", "check", "checkall", "modal_no_hosts_selected",
        "replace_label", "replace_checkbox"]

    changeHostgroup() {
        this.submitTarget.click();
    }

    submitHosts(event) {
        const isAllUnchecked = this.checkTargets.every(check => !check.checked)
        if (isAllUnchecked) {
            event.preventDefault()
            this.modal_no_hosts_selectedTarget.click();
        }
    }

    toggleAll() {
        this.checkTargets.forEach((checkbox) => {
            checkbox.checked = this.checkall
            this.switchHighlightRow(checkbox)
        })
    }

    checkByRowClick(event) {
        if (event.target.tagName !== 'INPUT') {
            let checkbox = event.target.parentElement.getElementsByTagName('input')[0]
            checkbox.checked = !checkbox.checked
            this.switchHighlightRow(checkbox)
        }
    }

    highlightRow(event) {
        this.switchHighlightRow(event.target)
    }

    switchHighlightRow(checkbox) {
        let tr = checkbox.parentNode.parentNode
        if (checkbox.checked) {
            tr.classList.add("table-info")
        } else {
            tr.classList.remove("table-info")
        }
    }

    underlineCheckboxLabel() {
        let rl = this.replace_labelTarget
        let rc = this.replace_checkboxTarget
        if (rc.checked) {
            rl.classList.add("underline")
        } else {
            rl.classList.remove("underline")
        }
    }

    get checkall() {
        return this.checkallTarget.checked
    }

    get hostgroup_id() {
        return this.hostgroup_idTarget.value
    }
}
