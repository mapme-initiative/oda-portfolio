
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
    xf1522833a4d242c5([""Up to date""]):::uptodate --- xb3df25f36846e314([""Errored""]):::errored
    xb3df25f36846e314([""Errored""]):::errored --- xd03d7c7dd2ddda2b([""Stem""]):::none
    xd03d7c7dd2ddda2b([""Stem""]):::none --- xbecb13963f49e50b{{""Object""}}:::none
    xbecb13963f49e50b{{""Object""}}:::none --- xeb2d7cac8a1ce544>""Function""]:::none
  end
  subgraph Graph
    direction LR
    xdab47f56eb6391e1(["fz_portfolio"]):::uptodate --> x9618f2e9856d1918(["indicators_wdpa"]):::errored
    x04d189518bd5d6b0{{"mapme_opts"}}:::uptodate --> x9618f2e9856d1918(["indicators_wdpa"]):::errored
    x976d8a71b32c2f2b>"run_mapme_indicators"]:::uptodate --> x9618f2e9856d1918(["indicators_wdpa"]):::errored
    x04d189518bd5d6b0{{"mapme_opts"}}:::uptodate --> xdab47f56eb6391e1(["fz_portfolio"]):::uptodate
    xa103919beeeaa1d5>"read_portfolio_data"]:::uptodate --> xdab47f56eb6391e1(["fz_portfolio"]):::uptodate
    x016a9b304ce9de80{{"expected_mapme_opts"}}:::uptodate --> x016a9b304ce9de80{{"expected_mapme_opts"}}:::uptodate
  end
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef errored stroke:#000000,color:#ffffff,fill:#C93312;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
  linkStyle 2 stroke-width:0px;
  linkStyle 3 stroke-width:0px;
  linkStyle 9 stroke-width:0px;
```

To run the pipeline adjust `_targets.R` and `config-oecd-countries.yaml`
to your local settings and then run the following from a shell:

``` shell
$ Rscript -e 'targets::tar_make()'
```
