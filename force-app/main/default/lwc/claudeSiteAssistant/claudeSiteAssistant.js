import { LightningElement } from 'lwc';
import askKnowledge from '@salesforce/apex/ClaudeSiteService.askKnowledge';

const MIN_GAP_MS = 5000; // client-side courtesy. The real limit belongs on the AWS side.

export default class ClaudeSiteAssistant extends LightningElement {
    question = '';
    answer;
    error;
    loading = false;
    lastAskedAt = 0;

    get disabled() {
        return this.loading || this.question.trim().length === 0;
    }

    handleChange(event) {
        this.question = event.target.value;
    }

    async handleAsk() {
        if (Date.now() - this.lastAskedAt < MIN_GAP_MS) {
            this.error = 'Please wait a few seconds before asking again.';
            return;
        }
        this.lastAskedAt = Date.now();
        this.loading = true;
        this.error = undefined;
        this.answer = undefined;
        try {
            this.answer = await askKnowledge({ question: this.question });
        } catch (e) {
            this.error = e?.body?.message ?? 'Something went wrong. Please try again.';
        } finally {
            this.loading = false;
        }
    }
}
