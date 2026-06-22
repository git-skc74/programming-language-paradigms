# Prefix Notation Calculator

CS4337 Project 1  
Bo Seong Kim  
March 6, 2026  

## Modes
It supports two mode: interactive and batch.
1. In runs in batch mode with "-b" or "--batch" flag.
2. Otherwise, It runs in interactive mode.


## How to Run
### Interactive mode:
```
racket calculator.rkt
```
### Batch mode:
```
racket calculator.rkt -b
```   
Example:
```
echo "+ 1 2" | racket calculator.rkt -b
```
### Quit:
```
input ('quit' to exit): quit
```

## Expressions:
Expressions are written in prefix notation, read from left to right.  
|Expression|Description|Example|
|---|---|---|
|`+ n n`| Addition | `+ 1 2` → 3 |
| `* n n`| Multiplication | `* 3 4` → `12` |
| `/ n n`| Integer division | `/ 10 3` → `3` |
| `- n` | Negation (unary) | `- 5` → `-5` |
| `$n` | History reference | `$1` → 1st result |
| number | A value | `42` |

Whitespace can be used to divide tokens like `$2 1`.  
Otherwise optional: `+*2$1 1` and `+ * 2 $1 1` are equivalent.

## History
Every successful result is saved to history and printed with its id.
```
1: 10.0
2: 4.0
3: 18.0
```
History values can be referenced with `$n` (e.g. `$1`, `$2`).

## Error Handling
All errors are printed in the format `Error: Invalid Expression` and the program continues running. History is not updated on errors.

Possible errors:
- Division by zero
- Invalid history reference (e.g. `$5` when history has fewer than 5 entries)
- Leftover tokens (e.g. `+ 1 2 3`)
- Unknown characters or incomplete expressions
EOF

## Notes
- Numbers are parsed greedily, so `+12 3` is parsed as `+`, `12`, and `3`, not `+`, `1`, `2`, `3`.