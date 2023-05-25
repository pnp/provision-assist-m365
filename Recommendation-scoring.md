# Recommendation Scoring

![Recommendation scoring list screenshit](/Images/RecommendationScoring.png)

Provision Assist includes functionality to recommend a type of collaboration space to a user based on their requirements they select when making the request.

This functionality is configured through a list named 'Recommendation Scoring' in the Provision Assist SharePoint site.

This list maps a 'requirement' (Requirement field) to a type of collaboration space e.g. 'Microsoft Teams Team', 'Communication Site' etc.

Sample requirement statements (list items) are included with the solution e.g. 'Work on a Project/Product', you may use these, edit, delete or add new ones as required.

Each requirement statement has a corresponding score for each type of collaboration space, these are stored in the columns that are named by the type of collaboration space. 

Columns exist with numeric values for each type of collaboration space, these values are the score for this space type. The higher the score, the more likely this collaboration space will be recommended to the user. The space with the highest scores is recommended (this is calculated in the Power App). There is no specific number format required, the higher the number, the greater the score.

Once requirements have been updated or scores changed, the Power App would need to be reopened by a user for the new requirements to be visible and the updated scores to take effect.

Experiment with different requirements and scores until you are happy the recommendations are correct for your organization. 
