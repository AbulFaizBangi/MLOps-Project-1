# Jupyter Notebook Documentation

## Navigation
- [Main Project Documentation](../README.md)
- [Setup Guide](../setup.md)
- [Project Blog](../blog.md)

# Hotel Booking Cancellation Prediction Project

## Initial Setup and Data Loading

### 1. Importing Required Libraries
```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
```
This block imports essential libraries:
- pandas: For data manipulation and analysis
- numpy: For numerical operations
- matplotlib.pyplot: For creating visualizations
- seaborn: For enhanced statistical visualizations

### 2. Suppressing Warnings
```python
import warnings
warnings.simplefilter("ignore")
```
Warnings are suppressed to keep the notebook output clean and focused on important information.

### 3. Loading and Viewing Data
```python
df = pd.read_csv("train.csv")
df.head()
```
Loads the training dataset into a pandas DataFrame and displays the first few rows.

### 4. Data Cleaning
```python
df.drop(columns=['Unnamed: 0', 'Booking_ID'], inplace=True)
```
Removes unnecessary columns:
- 'Unnamed: 0': Index column
- 'Booking_ID': Unique identifier not useful for prediction

### 5. Data Exploration
Various commands to understand the data:
```python
df.shape  # Dataset dimensions
df.isnull().sum()  # Check for missing values
df.duplicated().sum()  # Check for duplicate entries
```

### 6. Feature Analysis
Examining various features:
- Number of adults/children
- Weekend/weekday nights
- Meal plans
- Car parking requirements
- Room types
- Arrival details
- Market segment
- Guest history

### 7. Handling Imbalanced Data
The dataset shows imbalance in booking status:
```python
from imblearn.over_sampling import SMOTE
smote = SMOTE(random_state=42)
X_res, y_res = smote.fit_resample(X, y)
```
SMOTE is used to create synthetic samples of the minority class.

### 8. Feature Selection
Using Random Forest for feature importance:
```python
model = RandomForestClassifier(random_state=42)
model.fit(X,y)
feature_importance = model.feature_importances_
```
Selected top 10 most important features for model training.

### 9. Model Selection
Tested multiple classifiers:
- Random Forest
- Logistic Regression
- Gradient Boosting
- SVM
- Decision Trees
- KNN
- Naive Bayes
- XGBoost
- AdaBoost
- LGBM

### 10. Model Training and Evaluation
```python
best_rf_model = random_search.best_estimator_
y_pred = best_rf_model.predict(X_test)
```
Final model selection and hyperparameter tuning using RandomizedSearchCV.

### 11. Production Considerations
LGBM was chosen for production despite slightly lower accuracy due to:
- Smaller model size (~4-5 MB vs 168 MB)
- Cost-effective for deployment
- Acceptable accuracy trade-off (86-87%)

### 12. Data Preprocessing Details

#### Handling Categorical Variables
```python
label_encoder = LabelEncoder()
for col in cat_cols:
    df[col] = label_encoder.fit_transform(df[col])
```
- Converted categorical variables into numerical format
- Preserved mappings for future reference and deployment
- Categorical columns include meal plans, room types, and market segments

#### Feature Importance Analysis
Top features by importance:
1. Lead time
2. Average price per room
3. Number of special requests
4. Arrival date
5. Number of previous cancellations
These features strongly influence booking cancellation predictions.

### 13. Model Performance Metrics
```python
metrics = {
    "Model": [],
    "Accuracy": [],
    "Precision": [],
    "Recall": [],
    "F1 Score": []
}
```
Performance comparison across models:
- Random Forest achieved ~88% accuracy
- LGBM achieved ~86% accuracy
- XGBoost achieved ~87% accuracy

### 14. Hyperparameter Tuning
RandomizedSearchCV parameters:
```python
params_dist={
    'n_estimators': randint(100,500),
    'max_depth': randint(10,50),
    'min_samples_split': randint(2,10),
    'min_samples_leaf': randint(1,5),
    'bootstrap': [True, False]
}
```
- Used 5-fold cross-validation
- Performed 5 iterations of random search
- Optimized for accuracy score

### 15. Model Deployment Preparation
```python
joblib.dump(best_rf_model,"random_forest.pkl")
```
Model serialization considerations:
- Saved model state for deployment
- Included feature names and preprocessing steps
- Documented input data requirements

### 16. LGBM Implementation Notes
Reasons for choosing LGBM in production:
1. Memory Efficiency:
   - Smaller serialized model size
   - Lower RAM requirements during inference
2. Speed:
   - Faster training time
   - Quicker prediction times
3. Cost Benefits:
   - Reduced cloud storage costs
   - Lower compute resource requirements
4. Performance:
   - Only 2-3% accuracy trade-off
   - Better handling of categorical variables

### 17. Testing and Validation
```python
new_data = np.array([190,1,93.5,9,8,4,5,2,0,0]).reshape(1,-1)
predictions = loaded_model.predict(new_data)
```
Model validation approach:
- Used hold-out test set
- Performed cross-validation
- Tested with new, unseen data
- Monitored for overfitting

### 18. Data Visualization Analysis

#### Distribution Plots
```python
def num_plot_dist(df, num_features):
    fig, axes = plt.subplots(len(num_features),2,figsize=(15,len(num_features)*5))
```
Purpose of visualization functions:
- Histogram + KDE plots: Show distribution of numerical features
- Box plots: Identify outliers and data spread
- Key insights helped in feature selection and preprocessing decisions

#### Categorical Analysis
```python
for cat_feature in cat_cols:
    plt.figure(figsize=(10,6))
    data[cat_feature].value_counts().plot(kind='bar')
```
Visualizations revealed:
- Room type distribution patterns
- Meal plan preferences
- Market segment distribution
- Booking patterns across different categories

### 19. Correlation Analysis
```python
corr = df.corr()
plt.figure(figsize=(10,10))
sns.heatmap(corr, linewidths=0.5)
```
Key correlation findings:
- Strong positive correlation between lead time and cancellation
- Negative correlation between special requests and cancellation
- Price correlation with market segment and room type
- Weekend/weekday nights relationships

### 20. Feature Engineering Decisions
Based on analysis:
1. Lead time was kept as primary feature
2. Combined weekend/weekday nights were meaningful
3. Special requests indicated customer commitment
4. Previous booking history was significant
5. Price variations impact was substantial

### 21. Final Model Performance

Key metrics achieved:
1. Accuracy: 86-88%
2. Precision: ~85%
3. Recall: ~87%
4. F1 Score: ~86%

Business Impact:
- Better resource allocation
- Improved revenue prediction
- Enhanced customer service
- Optimized booking strategies

### 22. Future Improvements
Potential enhancements:
1. Feature Engineering:
   - Create more derived features
   - Seasonal patterns analysis
2. Model Updates:
   - Regular retraining schedule
   - Online learning implementation
3. Monitoring:
   - Model drift detection
   - Performance metrics tracking