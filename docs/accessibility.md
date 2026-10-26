# Accessibility and language status

Zaka's UI is **English-only** in this build. There is no localisation framework
wired in and **no `Semantics` widget coverage** yet, so a screen-reader user does
not get reliable labels on the custom cards, charts and buttons. This is a
known gap, not a claim of accessibility.

## Language targets

The first non-English targets are:

1. **isiZulu**
2. **Setswana**
3. **Sesotho**

These are the languages most relevant to the cash-first, taxi-and-spaza user
this build is for. A translation needs more than strings: amounts, dates,
category labels, the runway sentence and the privacy notice all need review by
first-language speakers. Do not machine-translate a privacy notice and ship it.

## Monochrome contrast check

The theme is deliberately black, white and grey. The main text pairs were
measured with the WCAG relative-luminance formula on 26 October 2026. AA for
normal text is 4.5:1; AA for large text is 3:1.

| Pair | Ratio | Verdict |
|---|---:|---|
| Light body: `#09090B` on `#FFFFFF` | 19.90:1 | AA / AAA |
| Light muted: `#6B6B73` on `#FFFFFF` | 5.28:1 | AA |
| Light muted on chip: `#6B6B73` on `#F4F4F5` | 4.81:1 | AA |
| Light error: `#DC2626` on `#FFFFFF` | 4.83:1 | AA |
| Dark body: `#FFFFFF` on `#000000` | 21.00:1 | AA / AAA |
| Dark muted: `#A1A1AA` on `#000000` | 8.19:1 | AAA |
| Dark muted on chip: `#A1A1AA` on `#18181B` | 6.91:1 | AAA |
| Dark error: `#EF4444` on `#000000` | 5.58:1 | AA |
| Light nav unselected: 54% black on white | 4.74:1 | AA |
| Dark nav unselected: 54% white on black | 6.08:1 | AA |

Two fixes were made after the check:

- The light muted token moved from `#71717A` to `#6B6B73` because the old value
  was 4.40:1 on the `#F4F4F5` chip background, below AA.
- The light bottom-navigation unselected state moved from 45% to 54% black
  because 45% black was 3.36:1, below AA.

The check covers the palette, not every rendered combination. Disabled states,
thin 1 px borders and the 5 px chart/sparkline are not text and are not claimed
to meet a text ratio. A full audit with a screen reader and large-text scaling
is still needed.

## What is not covered

- No `Semantics` labels for the balance, runway, category bars or sparkline.
- No TalkBack test on a device in this revision.
- No dynamic-type / 200% text-scale test.
- No right-to-left or non-English layout test.
- No colour-blindness simulation beyond the monochrome palette.
- No accessibility statement or feedback route specifically for accessibility
  complaints; use the general feedback row.

## Next steps

1. Add `Semantics` labels to the balance, runway, cards and icon-only buttons.
2. Run TalkBack and 200% text scaling on a physical Android device.
3. Add `flutter_localizations` and an ARB workflow; translate isiZulu, Setswana
   and Sesotho with first-language review.
4. Add an accessibility line to the feedback screen.
5. Re-run the contrast check in both themes after any palette change.
