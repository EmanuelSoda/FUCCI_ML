# [Automated workflow for the cell cycle analysis of (non-)adherent cells using a machine learning approach]()

***Kourosh Hayatigolkhatmi**, **Chiara Soriani**, **Emanuel Soda**, Elena Ceccacci, Oualid El Menna, Sebastiano Peri, Ivan Negrelli, Giacomo Bertolini, Gian Martino Franchi, Roberta Carbone, Saverio Minucci, Simona Rodighiero*

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
