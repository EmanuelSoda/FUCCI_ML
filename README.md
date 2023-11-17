# [Automated workflow for the cell cycle analysis of (non-)adherent cells using a machine learning approach]()

***Kourosh Hayatigolkhatmi***^**1**^*, **Chiara Soriani***^**1**^*, **Emanuel Soda***^**1**^*, Elena Ceccacci*^1^*, Oualid El Menna*^1^*, Sebastiano Peri*^1^*, Ivan Negrelli*^2^*, Giacomo Bertolini*^2^*, Gian Martino Franchi*^2^*, Roberta Carbone*^2^*, Saverio Minucci*^1,3^*, Simona Rodighiero*^1^

^1^Department of Experimental Oncology, European Institute of Oncology-IRCCS, Via Adamello 16, 20139, Milano, Italy.

^2^Tethis S.p.A., Milan, Italy.

^3^Department of Oncology and Hemato-Oncology, University of Milan, Milan, Italy.

# Model Creation

The pipeline is created using the [tidymodels](https://www.tidymodels.org/) framework. The random forest model trained and stored as docker container can be found [here](https://hub.docker.com/repository/docker/emanuelsoda/rf_semi_sup/general) .

The model stored as `.rds` file can be found here

![The Machine Learning pipeline followed to create the quality model. Using timetk time-series associated features are extracted from the list of manually annotated tracks. A random forest model is then trained to predict whether a track is cycling or not.](images/model_creation.png)

# Inference

![An unannotated track can be fed to the model to predict whether it is cycling or not](images/inference.png)

After training the model, making predictions is straightforward. Simply load the trained model and utilize either the `parsnip::predict()` function or, alternatively, `parsnip::augment()`. The latter not only provides predictions but also includes the associated predicted probabilities.

```         
rf_model_quality <- 
  readr::read_rds("models/rf_model_semi_supervised0.9.rds")
  
parsnip::augment(rf_model_quality, tsfeature_tbl)
```

# Result

![Waterfall plot of the "sorted" and "splitted" cells. Each row corresponds to a cell.](images/result_1.png)

feweewdcef

![Boxplot of the cell phase duration of the first cell cycle. A total of 1116 cells were analysed, obtaining a mean (± SD) cell cycle duration of 24.5 ± 8.5 h.](images/result_2.png)
