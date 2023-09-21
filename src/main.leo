program guarded_feedback_0_5.aleo {

    struct Settings {
        ownedby: address,
        voting: u32,
        deposit: u64,
    }

    mapping settings: u8 => Settings;

    struct Report {
        id: field,
        counter: u128,
        security_deposit: u64,
        block_height: u32,
        content: field,
        solved: bool,
        comment: field,
        rewards: u64,
        claimed: bool,
    }

    // Enable counting the reports at the key 0u8
    mapping counter: u8 => u128;
    // Enable querying a report by the counter
    mapping reports: u128 => Report;
    // Enable querying a report by the id
    mapping ids: field => u128;


    // This record is used to give people tokens as a reward for submitting useful proposals
    record user {
        private owner: address,
        private amount: u64,
    }

    // This record is used to store the reports a user has made in the past privately
    record reported {
        private owner: address,
        private id: field,
    }

    // DApp Configuration Function: `configure`
    //
    // Description:
    // The `configure` function is a fundamental component of the DApp (Decentralized Application) and is responsible for configuring essential settings that govern its behavior. This function allows the DApp owner to customize various parameters, such as voting rules and security deposit requirements. The configuration process is finalized by calling the `finalize` function.
    //
    // Parameters:
    // - `voting` (Type: `u32`): This parameter represents the voting rules or settings for the DApp. It can be a numeric value that dictates how voting is conducted within the application.
    // - `security_deposit` (Type: `u64`): The `security_deposit` parameter defines the required deposit amount for users participating in the DApp. Users may need to provide this deposit as collateral when using certain DApp features.
    transition configure(
        public voting: u32,
        public security_deposit: u64,
    ) {
        let ownedby: address = self.caller;
        return then finalize(ownedby, voting, security_deposit);
    }
    finalize configure(public ownedby: address, public voting: u32, security_deposit: u64) {
        let new: Settings = Settings {
            ownedby: ownedby,
            voting: voting,
            deposit: security_deposit,
        };
        Mapping::set(settings, 0u8, new);
    }

    // Submission Function: `submit`
    //
    // Description:
    // The `submit` function is responsible for submitting content along with a security deposit and voting rules for the DApp. It generates a unique identifier (ID) for the submission and creates a new report. This report includes information about the owner, the content, and the submission's status. The submission process is finalized by calling the `finalize` function.
    //
    // Parameters:
    // - `content` (Type: `field`): The content to be submitted to the DApp.
    // - `security_deposit` (Type: `u64`): The security deposit required for this submission.
    // - `voting` (Type: `u32`): Voting rules associated with the submission.
    //
    // Returns:
    // - `(field, reported)`: A tuple containing the generated ID (`field`) and a `reported` struct representing the submission report.
    transition submit(
        private content: field,
        private security_deposit: u64,
        private voting: u32,
    ) -> (field, reported) {
        let intermediary_hash: field = BHP256::hash_to_field(self.caller);
        let key_stretching: field = BHP256::hash_to_field((intermediary_hash));
        let id: field = BHP256::hash_to_field(content.add(key_stretching));
        let new: reported = reported {
            owner: self.caller,
            id: id,
        };
        return (id, new) then finalize(content, security_deposit, id, voting);
    }
    finalize submit(public content: field,
    security_deposit: u64,
    id: field,
    voting: u32,)
    {
        // check if the security deposit matches the setting
        assert(Mapping::get(settings, 0u8).deposit == security_deposit);
        // update the counter
        let current_counter: u128 = Mapping::get_or_use(counter, 0u8, 0u128);
        let next_counter: u128 = current_counter + 1u128;
        Mapping::set(counter, 0u8, next_counter);
        // link the current count to the id
        Mapping::set(reports, next_counter, Report {
            id: id,
            counter: next_counter,
            security_deposit: security_deposit,
            block_height: block.height,
            content: content,
            solved: false,
            comment: 0field,
            rewards: 0u64,
            claimed: false,
        });
        Mapping::set(ids, id, next_counter);
    }

    // Response Submission Function: `respond`
    //
    // Description:
    // The `respond` function allows users to respond to a specific report identified by its `id`. Users can provide comments, rewards, and indicate if the issue has been solved. This function is intended for interacting with existing reports. The response process is finalized by calling the `finalize` function.
    //
    // Parameters:
    // - `id` (Type: `field`): The unique identifier (ID) of the report to which the response is directed.
    // - `comment` (Type: `field`): A field containing comments or additional information related to the response.
    // - `rewards` (Type: `u64`): The rewards, if any, offered for responding to the report.
    // - `solved` (Type: `bool`): A boolean value indicating whether the issue has been solved.
    transition respond(
        public id: field,
        public comment: field,
        public rewards: u64,
        public solved: bool,
    ) {
        let sender: address = self.caller;
        return then finalize(id, comment, rewards, solved, sender);
    }
    finalize respond(
        public id: field,
        public comment: field,
        public rewards: u64,
        public solved: bool,
        public sender: address,
    )
    {
        assert(sender == Mapping::get(settings, 0u8).ownedby);
        let report: Report = Mapping::get(reports, id);
        let new_report: Report = Report {
            id: report.id,
            counter: report.counter,
            security_deposit: report.security_deposit,
            block_height: report.block_height,
            content: report.content,
            solved: solved,
            comment: comment,
            rewards: rewards,
            claimed: report.claimed,
        };
        Mapping::set(reports, report.counter, new_report);
    }

    // Claim Reward Function: `claim`
    //
    // Description:
    // The `claim` function allows users to claim rewards associated with a specific report identified by its `id`. To claim a reward, the user must provide the same `id`, content, and rewards amount that were used in the original report submission. This function verifies the validity of the claim and pays out the rewards. The claim process is finalized by calling the `finalize` function.
    //
    // Parameters:
    // - `id` (Type: `field`): The unique identifier (ID) of the report for which rewards are being claimed.
    // - `content` (Type: `field`): The content associated with the original report.
    // - `rewards` (Type: `u64`): The rewards amount being claimed.
    //
    // Returns:
    // - `user`: A `user` struct representing the user who claimed the rewards.
    transition claim(
        private id: field, 
        private content: field, 
        private rewards: u64,
        ) -> user {
        // create a proof that this person is the original caller
        // get the content used originally
        let intermediary_hash: field = BHP256::hash_to_field(self.caller);
        let key_stretching: field = BHP256::hash_to_field((intermediary_hash));
        assert_eq(BHP256::hash_to_field(content.add(key_stretching)), id);
        let new: user = user {
            owner: self.caller,
            amount: rewards,
        };
        //Payout the claimed amount
        return new then finalize(id, rewards);
    }
    finalize claim(public id: field, public rewards: u64)
    {
        let report: Report = Mapping::get(reports, id);
        assert(report.claimed == false);
        assert(report.rewards == rewards);
        let new_report: Report = Report {
            id: report.id,
            counter: report.counter,
            security_deposit: report.security_deposit,
            block_height: report.block_height,
            content: report.content,
            solved: report.solved,
            comment: report.comment,
            rewards: report.rewards,
            claimed: true,
        };
        Mapping::set(reports, report.counter, new_report);
    }
}
