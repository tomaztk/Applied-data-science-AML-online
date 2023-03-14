# Applied Data Science with Azure Machine Learning in a day



## Module 5

Module 5 - **Using MLflow output, deploying, and retraining a model** will explore the registered models in MLflow and how to use the relevant model, retrain and watch the model performance. We will also set both real-time and batch deployment and explore endpoints and how to use them using Azure ML CLI.  The last part of this module will be focused on integrating the solution with Github and learning how to retrain the model with event-based triggers or scheduled triggers.

## Breakdown of Module

1. Using MLFlow output
2. DEploying a model
3. Retraining a model
4. Exploring the end-points
5. Retraining a model with event-based triggers or scheduled triggers



## Using MLflow output



```python
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

Check the runs:

```python
client.list_artifacts(run_id)
```


So, what is feature engineering? Is a general process and can involve both feature construction: adding new features from the existing data, and feature selection: choosing only the most important features for improving model performance, reducing data dimensionality, doing log-transformation, removing outliers, to do scaling (normalisation, standardisation), imputations, general transformation (and others, as polynomial), variable creation, variable extraction and so on.

One-hot encoding is another part of feature engineering, that we have seen in the previous post. and now, let’s create polynomial features of 2nd degree and train and transform the features.



## Deploying a model



```python
import numpy as np
y.value_counts(normalize=True)
 
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.tree import DecisionTreeClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
from sklearn.naive_bayes import GaussianNB
from sklearn.svm import SVC
from xgboost import XGBClassifier
from sklearn.metrics import roc_auc_score, recall_score, classification_report
from sklearn.model_selection import StratifiedKFold, cross_val_score, cross_validate
 
# model preps
models = []
models.append(('DT', DecisionTreeClassifier(random_state=42)))
models.append(('LR', LogisticRegression(random_state=42)))
models.append(('RF', RandomForestClassifier(random_state=42)))
models.append(('NB', GaussianNB())) 
models.append(('XGB', XGBClassifier(random_state=42)))
models.append(('KNN', KNeighborsClassifier())) 
models.append(('SVM', SVC(gamma='auto',random_state=42)))
 
 
# evaluate each model in turn
results_recall = []
results_roc_auc= []
names = []
recall= tp/ (tp+fn). Best value=1, worst value=0
scoring = ['recall', 'roc_auc']
 
for name, model in models:
        # split dataset into k folds. use one fold for validation and remaining k-1 folds for training
        skf= StratifiedKFold(n_splits=10, shuffle=True, random_state=42)
        cv_results = cross_validate(model, x_train, y_train, cv=skf, scoring=scoring)
        results_recall.append(cv_results['test_recall'])
        results_roc_auc.append(cv_results['test_roc_auc'])
        names.append(name)
 
        msg = "%s- recall:%f roc_auc:%f" % (name, cv_results['test_recall'].mean(),cv_results['test_roc_auc'].mean())
        print(msg)

```

## Retraining a model


### Create the model
`cd aml-batch-endpoint`

Execute the following command:
`az ml model create -f cloud/model.yml`

### Create the cluster
Execute the following command:

`az ml compute create -f cloud/cluster-cpu.yml``

### Create the endpoint
Execute the following commands:

```
az ml batch-endpoint create -f cloud/endpoint/endpoint.yml
az ml batch-deployment create -f cloud/endpoint/deployment.yml --set-default
```

### Invoke the endpoint
Execute the following command:

```
az ml batch-endpoint invoke --input sample-request --name endpoint-batch
```

### Get the prediction results
Go to the Azure ML portal, click on "Endpoints," "Batch endpoints," and click on the name of the endpoint. Then click on "Runs," and on the latest run, which is displayed at the top. Once the run has completed, write click on the circle that says "score," and choose "Access data." This will take you to the blob storage location where the prediction results are located.

### Delete the endpoint
Execute the fllowing command when you're done:

`az ml batch-endpoint delete -n endpoint-batch -y`




