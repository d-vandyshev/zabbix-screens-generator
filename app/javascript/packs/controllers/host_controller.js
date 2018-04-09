import {Controller} from 'stimulus'

export default class extends Controller {
    static targets = ["hostgroup_id", "submit", "check", "checkall", "message_no_host_selected", "modal"]

    changeHostgroup() {
        this.submitTarget.click();
    }

    submitHosts(event) {
        const isAllUnchecked = this.checkTargets.every(check => !check.checked)
        if (isAllUnchecked) {
            event.preventDefault()
            this.message_no_host_selectedTarget.classList.remove("invisible");
            console.log(`isallunchecked`)
            this.modalTarget.click();
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
