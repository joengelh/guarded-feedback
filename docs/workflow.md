Workflow/ User Story

1. A product owner starts a collaboration with guarded feedback to collect high quality feedback, as well as to interact with the community and reward efforts. Thereby, a smart contract is deployed that manages the feedback given and the rewards paid.

2. A user of a product wishes to give feedback and submits it anonymously on the platform. -> Input: [`Content`]

3. The company reviews the report and marks it solved, adds a comment and/or adds a reward for the submission to the user. -> Input: [`id`,`comment`,`rewards`,`solved`]

4. The user generates a proof by hashing the address and the content to claim the rewards payment. -> Input: [`id`,`content`,`rewards`]
