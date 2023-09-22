program guarded_feedback_0_8.aleo {

    struct Settings {
        owned_by: address,
    }

    mapping settings: u8 => Settings;

    struct Report {
        id: field,
        counter: u128,
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
    // The `configure` function is used to change the owner of the DApp. It allows the current owner to transfer ownership to a new address. The configuration process is finalized by calling the `finalize` function.
    //
    // Parameters:
    // - `new_owner` (Type: `address`): The address of the new owner to whom the DApp ownership will be transferred.
    //
    transition initialize_contract() {
        let sender: address = self.caller;
        return then finalize(sender);
    }
    finalize initialize_contract(public sender: address) {
        // Check if the app has been configured. If it has been, check if its the owner
        let new_settings: Settings = Settings {
            owned_by: sender,
        };
        Mapping::set(settings, 0u8, new_settings);
    }

    transition transfer_ownership(new_owner: address) {
        let sender: address = self.caller;
        return then finalize(sender, new_owner);
    }
    finalize transfer_ownership(public sender: address, public new_owner: address) {
        // Check if the app has been configured. If it has been, check if its the owner
        let current_settings: Settings = Mapping::get(settings, 0u8);
        assert(current_settings.owned_by == sender);
        Mapping::set(settings, 0u8, Settings {
            owned_by: new_owner,
        });
    }

    // Submission Function: `submit`
    //
    // Description:
    // The `submit` function is responsible for submitting content along with a security deposit and voting rules for the DApp. It generates a unique identifier (ID) for the submission and creates a new report. This report includes information about the owner, the content, and the submission's status. The submission process is finalized by calling the `finalize` function.
    //
    // Parameters:
    // - `content` (Type: `field`): The content to be submitted to the DApp.
    //
    // Returns:
    // - `(field, reported)`: A tuple containing the generated ID (`field`) and a `reported` struct representing the submission report.
    transition submit(
        private content: field,
    ) -> (field, reported) {
        let intermediary_hash: field = BHP256::hash_to_field(self.caller);
        let key_stretching: field = BHP256::hash_to_field((intermediary_hash));
        let id: field = BHP256::hash_to_field(content.add(key_stretching));
        let new: reported = reported {
            owner: self.caller,
            id: id,
        };
        return (id, new) then finalize(content, id);
    }
    finalize submit(public content: field,
    id: field,)
    {
        // update the counter
        let current_counter: u128 = Mapping::get_or_use(counter, 0u8, 0u128);
        let next_counter: u128 = current_counter + 1u128;
        Mapping::set(counter, 0u8, next_counter);
        // link the current count to the id
        Mapping::set(reports, next_counter, Report {
            id: id,
            counter: next_counter,
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
        public number: u128,
        public comment: field,
        public rewards: u64,
        public solved: bool,
    ) {
        let sender: address = self.caller;
        return then finalize(number, comment, rewards, solved, sender);
    }
    finalize respond(
        public number: u128,
        public comment: field,
        public rewards: u64,
        public solved: bool,
        public sender: address,
    )
    {
        // this will fail if the app is not configured
        let current_settings: Settings = Mapping::get(settings, 0u8);
        assert(current_settings.owned_by == sender);
        let report: Report = Mapping::get(reports, number);
        let new_report: Report = Report {
            id: report.id,
            counter: report.counter,
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
        private number: u128, 
        private content: field, 
        private rewards: u64,
        ) -> user {
        // create a proof that this person is the original caller
        // get the content used originally
        let intermediary_hash: field = BHP256::hash_to_field(self.caller);
        let key_stretching: field = BHP256::hash_to_field((intermediary_hash));
        let id: field = BHP256::hash_to_field(content.add(key_stretching));
        let new: user = user {
            owner: self.caller,
            amount: rewards,
        };
        //Payout the claimed amount
        return new then finalize(number, rewards, id);
    }
    finalize claim(public number: u128, public rewards: u64, public id: field)
    {
        let report: Report = Mapping::get(reports, number);
        assert(report.id == id);
        assert(report.claimed == false);
        assert(report.rewards == rewards);
        let new_report: Report = Report {
            id: report.id,
            counter: report.counter,
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
