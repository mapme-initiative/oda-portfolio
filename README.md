
<!-- README.md is generated from README.Rmd. Please edit that file -->

# oda-portfolio

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

The goal of oda-portfolio is to establish a pipeline with the
`{targets}` package to calculated indicators for all protected areas
within countries that received official development aid by OECD member
countries.

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

For this, ISO3 codes of ODA-receiving countries are retrieve from OECD
servers. Additional ISO3 codes that should be included anyways, should
be manually added to `additional_isos`.

To adjust the pipeline change the contents of `_targets.R` and
`config.yaml` to your local settings and then run the following from a
shell:

``` shell
$ Rscript -e 'targets::tar_make()'
```
