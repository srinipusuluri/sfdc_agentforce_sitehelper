import { LightningElement, api } from 'lwc';
import ask from '@salesforce/apex/ClaudeAgentService.ask';

export default class ClaudeCaseSummary extends LightningElement {
    @api recordId;
    answer;
    error;
    loading = false;

    async handleSummarize() {
        this.loading = true;
        this.error = undefined;
        this.answer = undefined;
        try {
            this.answer = await ask({
                agent: 'case-summary',
                question: 'Summarize this case and suggest next steps.',
                recordId: this.recordId
            });
        } catch (e) {
            this.error = e?.body?.message ?? 'Something went wrong. Please try again.';
        } finally {
            this.loading = false;
        }
    }
}
