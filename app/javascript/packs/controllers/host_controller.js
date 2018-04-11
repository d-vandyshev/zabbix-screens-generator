import {Controller} from 'stimulus'

export default class extends Controller {
    static targets = ["hostgroup_id", "submit", "check", "checkall", "modal_no_hosts_selected"]

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
        this.checkTargets.forEach((c) => {
            if (this.checkall) {
                c.checked = true
            } else {
                c.checked = false
            }
        })
    }

    get checkall() {
        return this.checkallTarget.checked
    }

    get hostgroup_id() {
        return this.hostgroup_idTarget.value
    }
}
