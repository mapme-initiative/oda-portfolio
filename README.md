
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

# oda-portfolio

The codes in this repository establish a pipeline with the
[`{targets}`](https://books.ropensci.org/targets/) package to calculated
a number of biodiversity related indicators for all protected areas
within countries that received official development aid by OECD member
countries.

For this, the World Database on Protected Areas (WDPA) is downloaded and
pre-processed to correct invalid geometries. From the OECD data sharing
platform, information about which countries received ODA is fetched.
Additional countries to be included in the analysis can be added by
manually listing ISO3 codes in a new line in the file called
[`additional_isos`](additional_isos).

Indicators are calculated using
[`mapme.pipelines`](https://github.com/mapme-initiative/mapme.pipelines).
The indicator configuration can be changed by adapting
[`config.yaml`](config.yaml).

High-level configuration, such as WDPA version, data directories and
outputs can be configured by adapting [`_targets.R`](_targets.R).

The pipeline currently consists of the following functionality:

- [`wdpa.R`](R/wdpa.R): fetching and pre-processing WDPA data
- [`oecd.R`](R/oecd.R): fetching OECD information and subsetting WDPA to
  respective ISO3 codes
- [`mapme.R`](R/mapme.R): indicator calculation with
  [`mapme.pipelines`](https://github.com/mapme-initiative/mapme.pipelines)

To run the pipeline, issue the following command in a shell:

``` shell
$ Rscript -e 'targets::tar_make()'
```

Together these routines establish the following pipeline:

``` mermaid
graph LR
  style Legend fill:#FFFFFF00,stroke:#000000;
  style Graph fill:#FFFFFF00,stroke:#000000;
  subgraph Legend
    direction LR
    xf1522833a4d242c5([""Up to date""]):::uptodate --- xd03d7c7dd2ddda2b([""Stem""]):::none
  end
  subgraph Graph
    direction LR
    xe48d19884caae6a1(["oecd_wdpas"]):::uptodate --> x9618f2e9856d1918(["indicators_wdpa"]):::uptodate
    x02e849c05d317ecb(["target_isos"]):::uptodate --> xe48d19884caae6a1(["oecd_wdpas"]):::uptodate
    xe3337c4dc7e5112a(["valid_wdpa"]):::uptodate --> xe48d19884caae6a1(["oecd_wdpas"]):::uptodate
    x2715fa8989f923a6(["raw_wdpa"]):::uptodate --> xe3337c4dc7e5112a(["valid_wdpa"]):::uptodate
    x6e1d21aa66fc04c7(["additional_isos"]):::uptodate --> x02e849c05d317ecb(["target_isos"]):::uptodate
    x6313b05bb926e61b(["oda_iso_codes"]):::uptodate --> x02e849c05d317ecb(["target_isos"]):::uptodate
    x0fa0b08105a7c0a2(["oda_recipients"]):::uptodate --> x02e849c05d317ecb(["target_isos"]):::uptodate
  end
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
```
