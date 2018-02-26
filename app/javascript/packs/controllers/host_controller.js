import { Controller } from 'stimulus'

export default class extends Controller {
    static targets = ["hostgroup_id"]

    changeHostgroup() {
        console.log(`Hello, ${this.hostgroup_id}!`)
    }

    get hostgroup_id() {
        return this.hostgroup_idTarget.value
    }
}
