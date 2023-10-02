program guarded_feedback_0_0_1.aleo {

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


    // On-chain storage of an `account` map, with `address` as the key,
    // and `u64` as the value.
    mapping account: address => u64;

    record token {
        // The token owner.
        owner: address,
        // The token amount.
        amount: u64,
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
    transition initialize_contract(public new_owner: address) {
        return then finalize(new_owner);
    }

    finalize initialize_contract(public new_owner: address) {
        // Check if the app has been configured. If it has been, check if its the owner
        let new_settings: Settings = Settings {
            owned_by: new_owner,
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
    // - `token`: A `token` struct representing the user who claimed the rewards.
    transition claim(
        private number: u128, 
        private content: field, 
        private rewards: u64,
        ) -> token {
        // create a proof that this person is the original caller
        // get the content used originally
        let intermediary_hash: field = BHP256::hash_to_field(self.caller);
        let key_stretching: field = BHP256::hash_to_field((intermediary_hash));
        let id: field = BHP256::hash_to_field(content.add(key_stretching));
        let new: token = token {
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

    /* Transfer */
    transition transfer_public(public receiver: address, public amount: u64) {
        // Transfer the tokens publicly, by invoking the computation on-chain.
        return then finalize(self.caller, receiver, amount);
    }

    finalize transfer_public(public sender: address, public receiver: address, public amount: u64) {
        // Decrements `account[sender]` by `amount`.
        // If `account[sender]` does not exist, it will be created.
        // If `account[sender] - amount` underflows, `transfer_public` is reverted.
        let sender_amount: u64 = Mapping::get_or_use(account, sender, 0u64);
        Mapping::set(account, sender, sender_amount - amount);
        
        // Increments `account[receiver]` by `amount`.
        // If `account[receiver]` does not exist, it will be created.
        // If `account[receiver] + amount` overflows, `transfer_public` is reverted.
        let receiver_amount: u64 = Mapping::get_or_use(account, receiver, 0u64);
        Mapping::set(account, receiver, receiver_amount + amount);
    }

    // The function `transfer_private` sends the specified token amount to the token receiver from the specified token record.
    transition transfer_private(sender: token, receiver: address, amount: u64) -> (token, token) {
        // Checks the given token record has sufficient balance.
        // This `sub` operation is safe, and the proof will fail if an overflow occurs.
        // `difference` holds the change amount to be returned to sender.
        let difference: u64 = sender.amount - amount;

        // Produce a token record with the change amount for the sender.
        let remaining: token = token {
            owner: sender.owner,
            amount: difference,
        };

        // Produce a token record for the specified receiver.
        let transferred: token = token {
            owner: receiver,
            amount: amount,
        };

        // Output the sender's change record and the receiver's record.
        return (remaining, transferred);
    }

    // The function `transfer_private_to_public` turns a specified token amount from a token record into public tokens for the specified receiver.
    // This function preserves privacy for the sender's record, however it publicly reveals the token receiver and the token amount.
    transition transfer_private_to_public(sender: token, public receiver: address, public amount: u64) -> token {
        // Checks the given token record has a sufficient token amount.
        // This `sub` operation is safe, and the proof will fail if an underflow occurs.
        // `difference` holds the change amount for the caller.
        let difference: u64 = sender.amount - amount;

        // Produces a token record with the change amount for the caller.
        let remaining: token = token {
            owner: sender.owner,
            amount: difference,
        };

        // Output the sender's change record.
        // Increment the token amount publicly for the token receiver.
        return remaining then finalize(receiver, amount);
    }

    finalize transfer_private_to_public(public receiver: address, public amount: u64) {
        // Increments `account[receiver]` by `amount`.
        // If `account[receiver]` does not exist, it will be created.
        // If `account[receiver] + amount` overflows, `transfer_private_to_public` is reverted.
        let receiver_amount: u64 = Mapping::get_or_use(account, receiver, 0u64);
        Mapping::set(account, receiver, receiver_amount + amount);
    }

    // The function `transfer_public_to_private` turns a specified token amount from `account` into a token record for the specified receiver.
    // This function preserves privacy for the receiver's record, however it publicly reveals the caller and the specified token amount.
    transition transfer_public_to_private(public receiver: address, public amount: u64) -> token {
        // Produces a token record for the token receiver.
        let transferred: token = token {
            owner: receiver,
            amount: amount,
        };

        // Output the receiver's record.
        // Decrement the token amount of the caller publicly.
        return transferred then finalize(self.caller, amount);
    }

    finalize transfer_public_to_private(public sender: address, public amount: u64) {
        // Decrements `account[sender]` by `amount`.
        // If `account[sender]` does not exist, it will be created.
        // If `account[sender] - amount` underflows, `transfer_public_to_private` is reverted.
        let sender_amount: u64 = Mapping::get_or_use(account, sender, 0u64);
        Mapping::set(account, sender, sender_amount - amount);
    }

    transition burn_public(public amount: u64) {
        return then finalize(self.caller, amount);
    }
    
    finalize burn_public(public sender: address, public amount: u64) {
        // Decrements `account[sender]` by `amount`.
        // If `account[sender]` does not exist, it will be created.
        // If `account[sender] - amount` underflows, `transfer_public_to_private` is reverted.
        let sender_amount: u64 = Mapping::get_or_use(account, sender, 0u64);
        Mapping::set(account, sender, sender_amount - amount);
    }
}
