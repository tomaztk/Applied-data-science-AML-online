# Applied Data Science with Azure Machine Learning in a day



## Module 6

Module 6 - **Building end-to-end solution** will deliver the complete experience for an end-to-end solution. This module will wrap up the previous four modules, by using an prediction model with an Azure ML job. We will deploy a model by using an online managed endpoint with the help of Azure ML CLI, register and track the model using MLflow, and create YAML for sweeping the model and instancing the inferring cluster for model consumption.


## End-to-End solution


### Workspace
The full name for the namespace is  azureml.core.workspace.Workspace with additional classes available, that I will not be covering.

One sample of a class is to create worskapce.

### Create new workspace

```python
from azureml.core import Workspace
ws = Workspace.create(name='AML_SQLBits2023',
                      subscription_id='{your-subscription-guid}',
                      resource_group='RG_AML_SQLBits2023',
                      create_resource_group=False,
                      location='eastus2'
                     )
```
And for example, store the settings in JSON file:

### Store settings to file
```python
ws.write_config(path=".", file_name="ws_AML_SQLBits2023_v2_config.json"
```


### Experiments
The full name for the namespace is   azureml.core.experiment.Experiment. It lets you create an experiment and manage it, run it and more.

```python
from azureml.core.experiment import Experiment
experiment = Experiment(workspace=ws, name='demo-experiment')
 
#list all the experiments
list_experiments = Experiment.list(ws)
list_experiments
```

You can also get all the runs for this experiment:


```python
list_runs = experiment.get_runs()
for run in list_runs:
    print(run.id)
```

### Model
The namespace for a run: azureml.core.model.Model and use model registration to store and version your models in the Azure cloud, in your workspace. Registered models are identified by name and version.

Create a simple model:

```python
from sklearn import svm
import joblib
import numpy as np
 
# customer ages
X_train = np.array([50, 17, 35, 23, 28, 40, 31, 29, 19, 62])
X_train = X_train.reshape(-1, 1)
# churn y/n
y_train = ["yes", "no", "no", "no", "yes", "yes", "yes", "no", "no", "yes"]
 
clf = svm.SVC(gamma=0.001, C=100.)
clf.fit(X_train, y_train)
 
joblib.dump(value=clf, filename="churn-model.pkl")
```

And you can register the model:


```py
from azureml.core.model import Model
 model = Model.register(workspace=ws, model_path="churn-model.pkl", model_name="churn-model-test")
```

### Environment
Python SDK namespace is azureml.core.environment. Environments specify the set of Python packages, environment variables, and software settings around your training and scoring scripts. In addition to Python, you can also configure PySpark, Docker and R for environments.

You can use namespace  Environment (or created object/asset) to make deployment and code reusable for training purposes at given docker images, configurations and compute type.

The general script is:

```python
from azureml.core.environment import Environment
Environment(name="MyDevEnvironment")
```
but you can use a Docker image and scale faster with:

```python
# environment variables
environment_file = "6_environment_settings.yaml"
environment_name    = "MyDevEnvironmentDocker"
 
from azureml.core import Environment
 
env = Environment.from_conda_specification(environment_name, environment_file)
env.docker.enabled = True
env.docker.base_image = (
    "mcr.microsoft.com/azureml/curated/minimal-ubuntu18.04-py37-cuda11.0.3-gpu-inference:10"
)
```

And we have a `YAML file` with stored dependencies for the Conda specifications. It hold the following instructions:

```txt
channels:
  - conda-forge
dependencies:
  - python=3.9
  - pip
  - pip:
    - azureml-defaults
    - torch==1.8.1
    - torchvision==0.9.1
    - pytorch-lightning==1.1.8
    - mlflow
    - azureml-mlflow
```



###Pipelines
Namespace for the pipeline in SDK is azureml.pipeline.core.pipeline.Pipeline. Pipeline is an automated workflow of a compute task. There can be many subtasks within a pipeline and are a series of instructions. It varies, from simple pipelines, like calling a single script (py file) to a series of steps for data preparation, logging and training configurations, training and validating for efficient repeatability, and deployment steps

An Azure Machine Learning pipeline is an automated workflow of a complete machine learning task. Subtasks are encapsulated as a series of steps within the pipeline. An Azure Machine Learning pipeline can be as simple as one step that calls a Python script. Pipelines include functionality for:

Namespace for step in SDK is azureml.pipeline.steps. A step is a single encapsulated instruction that creates a pipeline. We will take a single script name and use a function (in this namespace)

 It takes a script name and other optional parameters like arguments for the script, compute target, inputs and outputs. The following code is a simple example of a PythonScriptStep.

```python
#settings
 
blob_input_data = "iris.csv"
output_data1 = "output.csv"
compute_target = "SQLBits2023-ds12-v2"
project_folder = "/Users/tomaz.kastrun/outputs"
 
from azureml.pipeline.steps import PythonScriptStep
 
train_step = PythonScriptStep(
    script_name="train.py",
    arguments=["--input", blob_input_data, "--output", output_data1],
    inputs=[blob_input_data],
    outputs=[output_data1],
    compute_target=compute_target,
    source_directory=project_folder
)
```

And once we have at least one step, we can create a pipeline.

```python
ws = "AML_SQLBits2023"
 
from azureml.pipeline.core import Pipeline
 
pipeline = Pipeline(workspace=ws, steps=[train_step])
pipeline_run = experiment.submit(pipeline)
```

Pipelines needs to be published at the end:

```python
ws = "AML_SQLBits2023"
 
pipeline_run1 = Experiment(ws, 'Submit').submit(pipeline, regenerate_outputs=False)
print("Pipeline has been submitted")
```

Once the pipeline is submitted, you can also find it under “Assets” in navigation bar.
Each pipeline must have a compute attached!


### Batch scroring

We will import the needed Python libraries

```python
from azure.ai.ml import MLClient, Input
from azure.ai.ml.entities import (
    BatchEndpoint,
    BatchDeployment,
    Model,
    Environment,
    BatchRetrySettings,
    CodeConfiguration,
)
from azure.identity import DefaultAzureCredential
from azure.ai.ml.constants import AssetTypes, BatchDeploymentOutputAction
import random
import string
```


And create pipelines:
```python
from azureml.core import Experiment
from azureml.pipeline.core import Pipeline
 
pipeline = Pipeline(workspace=ws, steps=[batch_score_step])
pipeline_run = Experiment(ws, "Batch-Scoring").submit(pipeline)
Creates a new pipeline for batch scoring
```



And pipeline was create using Python SDK and the ParallelRunStep function.

```python
from azureml.pipeline.steps import ParallelRunStep
from datetime import datetime
import uuid
 
parallel_step_name = "batchscoring-" + datetime.now().strftime("%Y%m%d%H%M")
 
label_config = label_ds.as_named_input("labels_input").as_mount("/tmp/{}".format(str(uuid.uuid4())))
 
batch_score_step = ParallelRunStep(
    name=parallel_step_name,
    inputs=[input_images.as_named_input("input_images")],
    output=output_dir,
    arguments=["--model_name", "inception",
               "--labels_dir", label_config],
    side_inputs=[label_config],
    parallel_run_config=parallel_run_config,
    allow_reuse=False
)
```