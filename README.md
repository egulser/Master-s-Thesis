# The Labor Market in Turkey: Empirical Investigation of Polarization

Master's thesis, MA Programme in Economics, Graduate School of Social Sciences,
Yıldız Technical University, 2023.
Author: Evren Gülser · Supervisor: Prof. Dr. Ensar Yılmaz

**[Read the thesis (PDF)](MA-Thesis.pdf)**

## Abstract

The thesis studies the structural change of employment in Turkey using the
TurkStat Labour Force Survey, pooling 19 annual cross-sections from 2004 to
2022 split into two periods, 2004–2012 and 2012–2022. New task data sets
support a task-based analysis. One comes from workers' own assessments of
their job tasks (PIAAC). The other tracks how the task content of jobs
changes over time.

In the first period, employment growth rises almost monotonically with skill,
measured by the occupational median wage. In the second period the pattern is
closer to polarization, although large real wage increases blur the effect of
market forces. Changes in sectoral composition help shape the employment
shifts. The evidence points to wage polarization in 2004–2012 and job
polarization in 2012–2022. Occupation-specific characteristics are enough to
explain the wage polarization of the first period. Task measures at both the
occupation and the worker level are meaningful predictors in wage equations.

JEL: J21, J24, J31

## Building the PDF

Requirements: a TeX distribution with `pdflatex`, BibTeX and `latexmk` (TeX
Live 2023 or later).

```sh
latexmk            # writes .build/main.pdf
latexmk -c         # removes auxiliary files
```

## Repository layout

| Path | Content |
| --- | --- |
| `main.tex` | Document skeleton: front matter, the four chapters, references, appendix |
| `preamble.tex` | Packages and formatting |
| `frontmatter/` | Title page, Turkish (ÖZ) and English abstracts, contents, abbreviations |
| `chapters/` | `01-introduction`, `02-data-and-descriptive-analysis`, `03-empirical-analysis`, `04-concluding-remarks` |
| `appendix/` | Appendix |
| `tables/` | One file per table, prefixed by chapter (`ch2-`, `ch3-`, `appx-`) |
| `figs/` | Figures used in the thesis, one folder per chapter |
| `references.bib` | Bibliography (APA style via `apacite`) |
| `code/` | Stata replication code with a figure/table-to-script map; see [`code/README.md`](code/README.md) |
| `extras/` | Material that does not appear in the thesis (see below) |
| `legacy/MA-Thesis.lyx` | The original LyX source |
| `MA-Thesis.pdf` | Compiled thesis |

`extras/` holds:

- `unused-content/`: draft tables and an appendix section that were hidden in
  the LyX file and never printed.
- `figs-hidden/`: the figures those drafts use.
- `figures-unused/`: other figure versions, post-defence analyses by gender
  and region, and EPS copies of figures now used as PDF.
- `table-working-files/`: CSV, Excel and LyX files used to typeset the tables.

## About this version

The thesis was written in LyX. In 2026 it was converted to plain LaTeX: LyX
2.3.7 exported the source, which was then split into one file per chapter and
per table, and the preamble was cleaned. Checks:

- Before the fixes listed below, the converted source reproduced the PDF
  compiled from the LyX file in January 2024. The text was identical
  character by character, and all 97 pages matched pixel for pixel when
  compiled with the same TeX installation.
- Fixes to defects that were present in that PDF:
  - Three cross-references that printed as "??" now point to Figures 6, 13
    and 16.
  - The appendix heading "Apendix" is now "Appendix".
  - The tables are numbered 1–13. Before, the numbering skipped Table 7
    because a `longtable` inside a table float stepped the counter twice.
  - Two quotations in Chapters 1 and 2 had only an opening or only a
    closing quotation mark; both are now complete. Nine pairs of straight
    quotation marks are now typographic quotes, as in the rest of the thesis.
  - A stray `="` (a leftover from a spreadsheet export) is removed from the
    note of Table A6.

`legacy/MA-Thesis.lyx` is kept for reference only. It expects the original
`figs/` and `tables/` layout. To build it in LyX, check out commit `5135f8e`.

This is the article-format version of the thesis. The copy submitted to the
YÖK National Thesis Center uses the university template and adds the approval
page and acknowledgements. The wording also differs in places.

## Data

The analysis uses restricted TurkStat microdata, which cannot be shared. See
[`code/README.md`](code/README.md) for the data sources and how to request
access.

## Related work

The follow-up paper *Job Polarization: Evidence for Turkiye* (Gülser and
Yılmaz) has its own replication package:
<https://github.com/egulser/Replication-package-for-JP-paper>.
