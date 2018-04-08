import {Controller} from 'stimulus'

export default class extends Controller {
    static targets = ["hostgroup_id", "submit", "check", "checkall"]

    changeHostgroup() {
        this.submitTarget.click();
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
