import { Controller } from 'stimulus'

export default class extends Controller {
    static targets = ["hostgroup_id", "submit"]

    changeHostgroup() {
        console.log(`Hello, ${this.hostgroup_id}!`);
        this.submitTarget.click();
    }

    get hostgroup_id() {
        return this.hostgroup_idTarget.value
    }
}
