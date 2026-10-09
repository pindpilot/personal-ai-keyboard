# Personal AI Keyboard v1

Unsigned iOS 17+ container + embedded keyboard extension. Personal use. No API keys or signing credentials in source or IPA.

## How to use
1. ESign/Feather must sign both the container app and embedded keyboard extension. Signing/extension installation on a physical device is not yet verified.
2. Settings > General > Keyboard > Keyboards > Add New Keyboard > AI Keyboard. Enable Allow Full Access for network and clipboard features.
3. Open the keyboard's Setup panel. Privately paste a Workers AI token, Cloudflare account ID, and Tavily API key. These stay in the extension's own device-only Keychain. App Groups are not required.
4. Confirm Workers Free and Tavily Researcher with pay-as-you-go OFF. There is no paid fallback or retry loop.
5. Write a question with your usual keyboard in any language, select/copy it, switch using the globe, and tap Selected text/Paste question. Basic English keys edit the question inside the extension; full multilingual typing/autocorrect is not included.
6. Tap Ask. Live search uses Tavily basic search (1 credit) and displays sources. Read the answer and tap Insert or Copy. It never sends the host app's message.

Only the explicitly reviewed question is sent. The keyboard does not passively upload the host field, surrounding text or clipboard. Do not send passwords or private messages. Cloudflare and Tavily process the submitted question.

## Free limits
- Cloudflare Workers Free: 10,000 neurons/day, shared across models. Adapter uses @cf/meta/llama-3.1-8b-instruct.
- Tavily Researcher: 1,000 credits/month. Basic search, no auto-parameters or paid refill.
- These are finite quotas, not unlimited availability. Network/key/quota errors are displayed.
- Gemini API excluded because current API terms prohibit consumer use.

## Demo honesty
Simulator demo embeds the actual keyboard controller in a test preview. Its answer is labelled DEMO, NOT LIVE AI/SEARCH. This demonstrates UI and insertion into a simulated host field, not successful real provider calls, system keyboard enablement or ESign signing. Those require separate device checks.

Secure/password and phone-pad fields use Apple's keyboard; apps may block custom keyboards.

## Sources checked October 9, 2026
- https://developer.apple.com/documentation/uikit/creating-a-custom-keyboard
- https://developer.apple.com/documentation/uikit/configuring-open-access-for-a-custom-keyboard
- https://developer.apple.com/documentation/uikit/configuring-a-custom-keyboard-interface
- https://developer.apple.com/documentation/uikit/handling-text-interactions-in-custom-keyboards
- https://ai.google.dev/gemini-api/terms
- https://developers.cloudflare.com/workers-ai/platform/pricing/
- https://developers.cloudflare.com/workers-ai/models/llama-3.1-8b-instruct/
- https://help.tavily.com/articles/8816424538-pricing
- https://docs.tavily.com/documentation/api-credits
- https://docs.tavily.com/documentation/api-reference/endpoint/search
- https://tavily.com/terms
