
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
    x7420bd9270f8d27d([""Up to date""]):::uptodate --- x0a52b03877696646([""Outdated""]):::outdated
    x0a52b03877696646([""Outdated""]):::outdated --- xbf4603d6c2c2ad6b([""Stem""]):::none
    xbf4603d6c2c2ad6b([""Stem""]):::none --- xf0bce276fe2b9d3e>""Function""]:::none
    xf0bce276fe2b9d3e>""Function""]:::none --- x5bffbffeae195fc9{{""Object""}}:::none
  end
  subgraph Graph
    direction LR
    xcc7ed83343bdf8a1{{"lcos"}}:::uptodate --> x8856b6f5990a3ba8>"fetch_wdpa"]:::uptodate
    xcc7ed83343bdf8a1{{"lcos"}}:::uptodate --> x9d822cf0f859ce50>"make_valid"]:::uptodate
    xcc7ed83343bdf8a1{{"lcos"}}:::uptodate --> xbd265a4b9d1db63c>"subset_wdpa"]:::uptodate
    xb318f1ed264477a9{{"mapme_opts"}}:::uptodate --> xe11f8af622ddaa16(["indicators_wdpa"]):::outdated
    xfb4ac4c02bebf8e6(["oecd_wdpas"]):::uptodate --> xe11f8af622ddaa16(["indicators_wdpa"]):::outdated
    x895e315e834819a0>"run_mapme_indicators"]:::uptodate --> xe11f8af622ddaa16(["indicators_wdpa"]):::outdated
    xbd265a4b9d1db63c>"subset_wdpa"]:::uptodate --> xfb4ac4c02bebf8e6(["oecd_wdpas"]):::uptodate
    x22809eca128f81ae(["target_isos"]):::uptodate --> xfb4ac4c02bebf8e6(["oecd_wdpas"]):::uptodate
    xec33757279ddc42f(["valid_wdpa"]):::uptodate --> xfb4ac4c02bebf8e6(["oecd_wdpas"]):::uptodate
    x9d822cf0f859ce50>"make_valid"]:::uptodate --> xec33757279ddc42f(["valid_wdpa"]):::uptodate
    x6b39f6574778e7d1(["raw_wdpa"]):::uptodate --> xec33757279ddc42f(["valid_wdpa"]):::uptodate
    x319e910a6aad0021>"get_oda_recipients"]:::uptodate --> x3fdd82fbb50aeb4a(["oda_recipients"]):::uptodate
    x62b530d25a77493e(["additional_isos"]):::uptodate --> x22809eca128f81ae(["target_isos"]):::uptodate
    xa4155ee3dee9a125>"match_isos"]:::uptodate --> x22809eca128f81ae(["target_isos"]):::uptodate
    x219e90e900a739ff(["oda_iso_codes"]):::uptodate --> x22809eca128f81ae(["target_isos"]):::uptodate
    x3fdd82fbb50aeb4a(["oda_recipients"]):::uptodate --> x22809eca128f81ae(["target_isos"]):::uptodate
    x8856b6f5990a3ba8>"fetch_wdpa"]:::uptodate --> x6b39f6574778e7d1(["raw_wdpa"]):::uptodate
    xe996beafd3492a40{{"wdpa_opts"}}:::uptodate --> x6b39f6574778e7d1(["raw_wdpa"]):::uptodate
    x3e3995729419150e>"get_oda_iso_codes"]:::uptodate --> x219e90e900a739ff(["oda_iso_codes"]):::uptodate
  end
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef outdated stroke:#000000,color:#000000,fill:#78B7C5;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
  linkStyle 2 stroke-width:0px;
  linkStyle 3 stroke-width:0px;
```

To run the pipeline adjust `_targets.R` and `config-oecd-countries.yaml`
to your local settings and then run the following from a shell:

``` shell
$ Rscript -e 'targets::tar_make()'
```
