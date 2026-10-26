# Replication code

Stata programs behind the figures and tables of the thesis. The files are
copied byte-for-byte from the author's working folders (2022–2023) and were
not edited for this repository; `MANIFEST.tsv` records each file's SHA-256,
last-modified date and original location.

These are research scripts, not a push-button package. Read the caveats below
before running anything.

## Data

The microdata cannot be redistributed and are **not** included.

| Source | Use | Access |
| --- | --- | --- |
| TurkStat Household Labour Force Survey (HLFS / LFS), annual cross-sections 2004–2022 | all employment and wage results | Apply to TurkStat (TÜİK) for the micro data sets |
| O\*NET | task content of occupations | Public |
| OECD PIAAC (Turkey) | individual-level task measures, PIAAC-based RTI | Public-use files from the OECD |
| ILO ISCO-88 / ISCO-08 classifications and crosswalk | occupation coding | Public |

## Software

Stata 17. User-written packages: `estout` (`eststo`, `esttab`), `grc1leg`,
`fre`, `outreg2` (install with `ssc install <name>`; `grc1leg` comes from
`net from http://www.stata.com/users/vwiggins`).

## Layout and run order

| Folder | Thesis section | Content |
| --- | --- | --- |
| `01-data/` | 2 (Data) | LFS harmonisation 2004–2022, ISCO crosswalks, CPI/GDP deflators, construction of the `<year>_v6` analysis files from `<year>_v3` |
| `02-descriptives/` | 2.1 | Summary statistics; `education-wage-pipeline/` adapts the Acemoglu and Autor (2011) composition-adjusted wage and labour-supply code to the LFS (run `launcher.do`, then the plotting files); 90/50/10 percentile series |
| `03-polarization/` | 2.3 | Smoothed and observed changes in employment shares by skill percentile; routine share by percentile |
| `04-tasks/` | 2.4 | O\*NET task measures (`task_construct.do`), employment and wages by task and sector, industry growth |
| `05-empirical/` | 3 | Polarization tests and RTI regressions, decile wage changes, task–wage relationship |

Caveats:

- **Paths.** Every script sets absolute paths on the author's machine
  (`/Users/evrengulser/...`). Edit the `cd`, `global` and `local` path lines
  at the top of each file first.
- **Missing step.** The `<year>_v3` files that most scripts load were built
  from the harmonised LFS by an intermediate script that did not survive.
  `01-data/harmonize_lfs_2004_2022.do` produces the harmonised yearly files.
  `01-data/preparation_v6.do` turns `_v3` into `_v6`.
- `05-empirical/task_wage_relationship_2004_2012.do` calls
  `do/task_construct.do`. That file is in `04-tasks/`.
- Tables were assembled by hand from Stata output (`esttab`, `tabulate`,
  `summarize`). The scripts reproduce the estimates, not the typeset tables.

## Where each figure and table comes from

Status: **E** the script exports the file used in the thesis (same name) ·
**R** the script exports this figure under another name, matched by title and
content · **L** only a version edited after the defence survives · **N** code
not found · **X** reproduced from published material, no code.

| Thesis | Content | File in `figs/` or `tables/` | Script | Status |
| --- | --- | --- | --- | --- |
| Figure 1 | US employment and wage changes, 1980–2005 | `ch1/autor-dorn-2013.pdf` | — (Autor and Dorn, 2013) | X |
| Figure 2 | Hours shares by education and gender | `ch2/educ-hour-shares-mf-2004-2020.pdf` | `02-descriptives/education-wage-pipeline/labor_supply_shares_plot.do` | E |
| Figure 3 | College/high-school wage ratio and relative supply | `ch2/college-hs-*-comp-adj.pdf` | `02-descriptives/education-wage-pipeline/fig1_2_3_19_20_21.do` (`1.eps`, `2.eps`) | R |
| Figure 4 | Composition-adjusted log real wages, M+F | `ch2/comp-adj-log-wages-mf-2004-2020.pdf` | `02-descriptives/education-wage-pipeline/plotfig_AA_lfs.do` | R |
| Figure 5 | 90th/50th/10th percentile wage growth | `ch2/wage-percentiles-90-50-10-mf.pdf` | `02-descriptives/wage_percentiles_90_50_10.do` | R |
| Figure 6 | Smoothed/observed employment-share changes | `ch2/polarization-*.pdf`, `ch2/lowess-*.pdf` | `03-polarization/polarization_2004_2012.do`, `_2012_2022.do`, `_2004_2022.do` | E |
| Figure 7 | Routine share by skill percentile | `ch2/routine-occupation-share-2004-2022.pdf` | `03-polarization/routine_share_by_skill_percentile.do` | E |
| Figure 8a | Employment changes by task and sector | `ch2/employment-by-task-sector.pdf` | `04-tasks/employment_by_task_and_sector.do` | L |
| Figure 8b | Real wage changes by task and sector | `ch2/wages-by-task-sector.pdf` | `04-tasks/wages_by_task_and_sector.do` | E |
| Figure 9 | Employment by six task categories | `ch2/allsectors-alltasks-2004-2022-area.pdf` | `04-tasks/allsectors_alltasks_2004_2022.do` | E |
| Figure 10 | Wage and employment change over RTI | `ch3/rti-*.pdf` | `05-empirical/polarization_tests_and_rti.do` | E |
| Figure 11 | Real log wage changes by decile | `ch3/decile-wage-changes-*.pdf` | `05-empirical/decile_wage_changes.do` | E |
| Figure 12 | Task components | `appendix/alm-2003-task-definitions.png` | — (Autor, Levy and Murnane, 2003) | X |
| Figure 13 | College/high-school supply by experience | `appendix/college-hs-supply-exp-*.pdf` | `02-descriptives/education-wage-pipeline/fig1_2_3_19_20_21.do` (`5.eps`, `6.eps`) | R |
| Figure 14a | Employment growth by industry (bars) | `appendix/industry-employment-growth.pdf` | — | N |
| Figure 14b | Employment-share growth by industry | `appendix/industry-employment-share-growth.pdf` | `04-tasks/industry_employment_growth.do` | E |
| Figure 15 | Employment shares of occupational groups | `appendix/isco-*-employment-shares.pdf` | — | N |
| Figure 16 | Composition-adjusted log real wages, F and M | `appendix/comp-adj-log-wages-[fm]-2004-2020.pdf` | `02-descriptives/education-wage-pipeline/plotfig_AA_lfs.do` | E |
| Figure 17 | Mean wages and task importance | `appendix/task-wage-relationship-2004-2012.pdf` | `05-empirical/task_wage_relationship_2004_2012.do` | E |
| Figure 18 | Country-specific task measures (a table set as a figure) | in `appendix/appendix.tex` | — | N |
| Tables 1–2 | Summary statistics | `ch2-01-*`, `ch2-02-*` | `02-descriptives/summary_statistics.do`, `main_descriptive_table.do` | R |
| Table 3 | Shift-share decomposition | `ch2-03-shift-share-decomposition.tex` | — (a later version with other periods exists outside this repository) | N |
| Table 4 | Changes in hours shares by occupation, 2004–2012 | `ch2-04-*` | — | N |
| Table 5 | Task intensity of major occupation groups (signs only) | `ch2-05-*` | — (summary written by hand) | N |
| Tables 6, A3, A5 | O\*NET task measures by occupation group and by ISCO code | `ch2-06-*`, `appx-03-*`, `appx-05-*` | `04-tasks/task_construct.do` | R |
| Tables 7–10 | Task scores and wage functions with tasks | `ch3-01-*` … `ch3-04-*` | — | N |
| Tables 11–12, A6 | Polarization tests, RTI regressions | `ch3-05-*`, `ch3-06-*`, `appx-06-*` | `05-empirical/polarization_tests_and_rti.do` | R |
| Table 13 | Decile wage regressions by occupation | `ch3-07-*` | `05-empirical/decile_wage_changes.do` | R |
| Tables A1, A2, A7, A8, A11 | ISCO codes, task definitions, coding changes, ISCO-88/08 transition matrix | `appx-01`, `appx-02`, `appx-07`, `appx-08`, `appx-11` | — (ILO / TurkStat documentation, Acemoglu and Autor, 2011) | X |
| Tables A4, A9, A10 | RTI ranking, task correlations, occupation–task allocation | `appx-04`, `appx-09`, `appx-10` | — | N |

## Related

The follow-up paper *Job Polarization: Evidence for Turkiye* (Gülser and
Yılmaz) has its own, cleaner replication package:
<https://github.com/egulser/Replication-package-for-JP-paper>. Its O\*NET task
code is the same `task_construct.do` used here.
