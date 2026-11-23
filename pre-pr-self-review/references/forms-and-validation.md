# Forms, validation and UI states

Read this when the change adds or edits form fields, validation, error messages or interactive UI states. A spec usually describes these precisely, so check each one against the code and the tests.

Contents: Inputs and validation · State changes · Error messages and copy · Accessibility · Responsive and other surfaces

## Inputs and validation

- **Every rule in the spec has code and a test.** List them: required or optional, allowed range, accepted and rejected formats, conditional rules ("required only if X > 0").
- **Blank vs zero vs invalid** are three different cases. Check each separately.
- **Conditional fields**: when a field doesn't apply (disabled, hidden, count is zero) it should be ignored in validation and calculation, and shouldn't block submit.
- **Both sides of each boundary**: just valid and just invalid (for example overhead 0 and 100 accepted, -1 and 101 rejected).
- **Parsing**: whitespace, pasted values with separators or currency symbols, decimal formats, non-finite values, very long input.
- **Fractional or negative counts**, or text where a number is expected.
- **Validation order**: if several rules fail, is the behaviour (which error shows, whether results are suppressed) what the spec says?

## State changes

- Does changing an input **clear the previous result** and the errors that no longer apply?
- Does changing a selection (a preset, a role type) update only what the spec says and leave user-entered values alone?
- Does **reset / retry** clear everything the spec lists (results, errors, entered amounts) and restore defaults, but not more?
- **Disabled or locked** fields: are they also cleared or ignored, as specified, when the condition changes?
- Initial state: no errors and no result until the user acts.

## Error messages and copy

- **Exact strings.** Compare every label, help text, error message and result label against the spec character by character, including punctuation and capitalisation. Search the code for old strings that should be gone.
- **Removed features are really gone**: old controls, tooltips, constants, validation and unused imports, not just hidden.
- Display of empty or not-applicable values (`N/A`, `$0`) as specified.

## Accessibility

- Each visible label is tied to its control (unique id).
- Help and example text connected with `aria-describedby`; invalid fields marked `aria-invalid` and linked to their error text.
- On submit with errors, **focus moves** to the first invalid field or the form error.
- Results announced with a live region (`role="status"`) without stealing keyboard focus; the region is mounted before content changes.
- Inputs use the right type and hints (for example `inputmode="decimal"` for amounts that allow formatting).
- Keyboard-only: can the whole flow be completed, and is the focus order sensible?
- Say plainly which of these need a manual or screen-reader check; code reading alone can't confirm them.

## Responsive and other surfaces

- Layout at a narrow width (about 375px) and on desktop; any call-to-action preserved on both.
- Other places that show the same information: FAQ answers, docs, tracker rows, emails, marketing copy. The change isn't finished if those still say the old thing.
- Release dependencies: copy or content that must go live together with the code.
