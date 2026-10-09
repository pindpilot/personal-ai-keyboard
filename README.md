# Personal AI Keyboard (private work in progress)

Provider-neutral shell. No compiled IPA or live AI connection exists yet.

This extension explicitly loads selected or pasted questions, displays a reviewed answer and inserts it using UITextDocumentProxy. It does not read surrounding messages in the background or send messages.

## Pending
- Owner's new-repo audience decision and provider approval.
- Cloudflare Workers Free plan and model eligibility, Tavily Researcher/adult eligibility.
- Secure extension-only API-key setup, matching ESign signing of embedded appex.
- Xcode compile, simulator enablement, actual UI recording and inspection.

Demo builds must clearly label fixture answers as DEMO, NOT LIVE AI/SEARCH. Never bundle the owner's API keys in source, CI logs or an IPA.

## Sources checked October 9, 2026
- https://developer.apple.com/documentation/uikit/creating-a-custom-keyboard
- https://developer.apple.com/documentation/uikit/configuring-open-access-for-a-custom-keyboard
- https://developer.apple.com/documentation/uikit/configuring-a-custom-keyboard-interface
- https://developer.apple.com/documentation/uikit/handling-text-interactions-in-custom-keyboards
- https://developer.apple.com/documentation/xcode/configuring-app-groups
- https://ai.google.dev/gemini-api/terms (Gemini API excluded for consumer personal use)
- https://developers.cloudflare.com/workers-ai/platform/pricing/
- https://developers.cloudflare.com/workers-ai/models/llama-3.1-8b-instruct/
- https://help.tavily.com/articles/8816424538-pricing
- https://docs.tavily.com/documentation/api-credits
- https://tavily.com/terms
