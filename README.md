
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

This branch was created for processing the FZ portfolio data.

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
    x721addc77afbcf42(["input_file"]):::uptodate --> x16b7b3078fdccc78(["pa_output_word"]):::uptodate
    xa355481dcc1a3b39(["pa_data"]):::uptodate --> x16b7b3078fdccc78(["pa_output_word"]):::uptodate
    x31d8d3daa8f8e034(["activites_enriched"]):::uptodate --> xa355481dcc1a3b39(["pa_data"]):::uptodate
    x31d8d3daa8f8e034(["activites_enriched"]):::uptodate --> x87ba475ce69b80a8(["gpkg_output"]):::uptodate
    x721addc77afbcf42(["input_file"]):::uptodate --> x87ba475ce69b80a8(["gpkg_output"]):::uptodate
    x721addc77afbcf42(["input_file"]):::uptodate --> x9be9fe4c25e464e0(["activity_data"]):::uptodate
    xd80c6efdd95a74a4(["indicators_locations"]):::uptodate --> x1ba9c4ef45365262(["summarised_indicators"]):::uptodate
    x9be9fe4c25e464e0(["activity_data"]):::uptodate --> x901ac07110e697ee(["unique_locations"]):::uptodate
    x721addc77afbcf42(["input_file"]):::uptodate --> x901ac07110e697ee(["unique_locations"]):::uptodate
    x721addc77afbcf42(["input_file"]):::uptodate --> xf39fc5dec6b9a973(["pa_output_excel"]):::uptodate
    xa355481dcc1a3b39(["pa_data"]):::uptodate --> xf39fc5dec6b9a973(["pa_output_excel"]):::uptodate
    x9be9fe4c25e464e0(["activity_data"]):::uptodate --> x31d8d3daa8f8e034(["activites_enriched"]):::uptodate
    x721addc77afbcf42(["input_file"]):::uptodate --> x31d8d3daa8f8e034(["activites_enriched"]):::uptodate
    x1ba9c4ef45365262(["summarised_indicators"]):::uptodate --> x31d8d3daa8f8e034(["activites_enriched"]):::uptodate
    x31d8d3daa8f8e034(["activites_enriched"]):::uptodate --> x79629de1855e879d(["excel_output"]):::uptodate
    x721addc77afbcf42(["input_file"]):::uptodate --> x79629de1855e879d(["excel_output"]):::uptodate
    x9909b451a6a56060(["config_file"]):::uptodate --> xd80c6efdd95a74a4(["indicators_locations"]):::uptodate
    x901ac07110e697ee(["unique_locations"]):::uptodate --> xd80c6efdd95a74a4(["indicators_locations"]):::uptodate
  end
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
```

To run the pipeline adjust `_targets.R` and `config-oecd-countries.yaml`
to your local settings and then run the following from a shell:

``` shell
$ Rscript -e 'targets::tar_make()'
```
