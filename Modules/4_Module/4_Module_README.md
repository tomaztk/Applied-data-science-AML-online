# Applied Data Science with Azure Machine Learning in a day



## Module 4

Module 4 - **Preparing the models, running experiments, and training the model** will teach you how to configure a job run, configure the compute and consume data from a job. With the help of notebooks, we will evaluate a model, and train and track the model using MLflow. After the process will be completed, we will implement a training pipeline, learn how to pass data between the steps and also take a look into using custom components and component-based pipelines.



## Breakdown of Module

1. Prepare the model
2. Run the experiments
3. Traing the model
4. Use MLFlow
5. IMplementing training pipeline


For preparing the models, check the Analysis-Module4.ipynb.



## 4. Using MLFlow


MLFlow is an open-source framework for registering, managing and tracking machine learning models. It is multiplatform, bringing consistent model training and model consumption across different platforms. This means, that training a model locally and uploading it to Azure or training a model on remote compute instances and downloading it, is a great feature for MLflow.

You can use MLflow with Azure CLI, Azure Python SDK or in the studio and it will deliver a consistent experience (note, some functionalities are limited to the language).

It offers model registering and logging, and model deployment.

By opening a new notebook and attaching it to the compute, you can start setting up the MLflow.

```Python
from azure.ai.ml import MLClient
from azure.identity import DefaultAzureCredential

ml_client = MLClient.from_config(credential=DefaultAzureCredential())
```

### Get MLflow URI
```
mlflow_tracking_uri = ml_client.workspaces.get(ml_client.workspace_name).mlflow_tracking_uri
```

### Configure tracking URI
```
import mlflow
mlflow.set_tracking_uri(mlflow_tracking_uri)
```

### To configure the experiment 
```
experiment_name = 'MLflow_experiment'
mlflow.set_experiment(experiment_name)
```


### Starting a new job
```
import os
from random import random

with mlflow.start_run() as mlflow_run:
    mlflow.log_param("hello_param", "world")
    mlflow.log_metric("hello_metric", random())
    os.system(f"echo 'hello world' > helloworld.txt")
    mlflow.log_artifact("helloworld.txt")
```


And we can also view the metrics and also artefacts, and also use MLflow to retrieve the job that was just completed.

```
from mlflow.tracking import MlflowClient

# Use MlFlow to retrieve the job that was just completed
client = MlflowClient()
run_id = mlflow_run.info.run_id
finished_mlflow_run = MlflowClient().get_run(run_id)

metrics = finished_mlflow_run.data.metrics
tags = finished_mlflow_run.data.tags
params = finished_mlflow_run.data.params

print(metrics,tags,params)
```


We use couple of important methods within the mlflow namespace:
* MLClient – to setup the credentials and getting the job runs and viewing metrics
* mlflow – to create and set the tracking URI and set the experiment


### Using MLFlow to train the models

We will create a new notebook and use Heart dataset (link to dataset) to toy around. We will also import xgboost classifier to asses the accuracy of the presence of heart disease in the patient. We will be using a categorical (integer) variable with values from 0 (no presence) to 4 (strong presence) and attempt to classify based on 15+ attributes (out of more than 70 attributes).

```python
#importing mlflow functions
import mlflow
mlflow.set_experiment(experiment_name="heart-condition-classifier")
 
#getting the data
import pandas as pd
file_url = "http://storage.googleapis.com/download.tensorflow.org/data/heart.csv"
df = pd.read_csv(file_url)
 
#some data engineering
df["thal"] = df["thal"].astype("category").cat.codes
 
#split train and test
from sklearn.model_selection import train_test_split
 
X_train, X_test, y_train, y_test = train_test_split(
    df.drop("target", axis=1), df["target"], test_size=0.4
)
 
#logging the steps
mlflow.xgboost.autolog()
 
#training the model
from xgboost import XGBClassifier
 
model = XGBClassifier(use_label_encoder=False, eval_metric="logloss")
 
#  start the  mlflow run
run = mlflow.start_run()
 
#start fitting the model
model.fit(X_train, y_train, eval_set=[(X_test, y_test)], verbose=False)
 
#logging some extra metrics
y_pred = model.predict(X_test)
 
from sklearn.metrics import accuracy_score, recall_score, fbeta_score, confusion_matrix
 
accuracy = accuracy_score(y_test, y_pred)
recall = recall_score(y_test, y_pred)
cm = confusion_matrix(y_test, y_pred)
 
#closing mlflow
mlflow.end_run()
run = mlflow.get_run(run.info.run_id)
client = mlflow.tracking.MlflowClient()
```

And now we want to do the logging with preprocessing.


```python
#using ordinal encoder
 
import numpy as np
from sklearn.preprocessing import OrdinalEncoder
 
# creating transformation and using Logloss on xbgoost classifies
from sklearn.compose import ColumnTransformer
from xgboost import XGBClassifier
 
encoder = ColumnTransformer(
    [
        (
            "cat_encoding",
            OrdinalEncoder(
                categories="auto",
                handle_unknown="use_encoded_value",
                unknown_value=np.nan,
            ),
            ["thal"],
        )
    ],
    remainder="passthrough",
    verbose_feature_names_out=False,
)
 
model = XGBClassifier(use_label_encoder=False, eval_metric="logloss")
```
With mulitple runs, you can also check the performance of models with desired metrics. This is an example of logloss validation and comparison between two runs.


