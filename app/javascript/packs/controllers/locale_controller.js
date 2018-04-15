import {Controller} from 'stimulus'

export default class extends Controller {
    static targets = ["submit"]

    changeLocale() {
        this.submitTarget.click();
    }
}
