// The 'guarded_feedback' program.
program guarded_feedback_0_1.aleo {

    struct Report {
        id: field,
        salt: field,
        security_deposit: u64,
        block_height: u32,
        content: field,
        votes_yes: u128,
        votes_no: u128,
        accepted: bool,
        rejected: bool,
        solved: bool,
        comment: field,
        rewards: u64,
        claimed: bool,
    }

    // Enable querying a report by the id
    mapping reports: field => Report;
    // This stores the count of all reports submitted
    mapping counter: u8 => u128;
    // Enable querying a report by its counter
    mapping counters: u128 => field;

    struct Settings {
        ownedby: address,
        voting: u32,
        deposit: u64,
    }

    // Settings are saved at position 0 of the mapping
    mapping settings: u8 => Settings;

    record user {
        owner: address,
        amount: u64,
    }

    transition configure(
        public voting_period: u32,
        public security_deposit: u64,
    ) {
        let ownedby: address = self.caller;
        return then finalize(ownedby, voting_period, security_deposit);
    }
    finalize configure(public ownedby: address, public voting_period: u32, security_deposit: u64) {
        let new: Settings = Settings {
            ownedby: ownedby,
            voting: voting_period,
            deposit: security_deposit,
        };
        Mapping::set(settings, 0u8, new);
    }

    transition reset(security_deposit: u64) -> user {
        let new: user = user {
        owner: self.caller,
        amount: security_deposit,
        };
        return new then finalize(security_deposit);
    } finalize reset(security_depost: u64) {
        assert(Mapping::get(settings, 0u8).deposit == security_depost);
    }

    // The transition is most likely run on the clients computer
    // Key Stretching and a random salt will be used to resist hashmaps and collisions, aswell as brute forcing
    transition submit(
        private content: field,
        private security_deposit: u64,
        private random_salt: field,
        private sender: user,
    ) -> user {
        let new: user = user {
            owner: self.caller,
            amount: sender.amount - security_deposit,
        };
        let intermediary_hash: field = BHP256::hash_to_field(self.caller);
        let key_stretching: field = BHP256::hash_to_field((intermediary_hash));
        let id: field = BHP256::hash_to_field(random_salt.add(key_stretching));
        return new then finalize(content, security_deposit, id, random_salt);
    }
    finalize submit(public content: field,
    public security_deposit: u64,
    public id: field,
    public random_salt: field,)
    {
        // check if the security deposit matches the setting
        assert(Mapping::get(settings, 0u8).deposit == security_deposit);
        // update the counter
        let current_counter: u128 = Mapping::get_or_use(counter, 0u8, 0u128);
        Mapping::set(counter, 0u8, current_counter + 1u128);
        // create the user struct and map it to the id
        Mapping::set(reports, id, Report {
            id: id,
            salt: random_salt,
            security_deposit: security_deposit,
            block_height: block.height,
            content: content,
            votes_yes: 0u128,
            votes_no: 0u128,
            accepted: false,
            rejected: false,
            solved: false,
            comment: 0field,
            rewards: 0u64,
            claimed: false,
        });
    }

    // Check if a voting was up for 48 hours, if that is the case, finalize it with the next vote
    // It is assumed that the block time is 16 seconds, however this can be reset by the owner

    transition yes(
        private id: field,
    ) {
        return then finalize(id);
    }
    finalize yes(
        public id: field,
    ) {
        assert(Mapping::contains(reports, id) == true);
        let report: Report = Mapping::get(reports, id);
        assert(report.accepted == false && report.rejected == false);
        // Get the voting period as blocks to be required to ahve passed
        let voting_period: u32 = Mapping::get(settings, 0u8).voting;
        
        // Check if voting has ended, if it has make the decision
        let current_block_height: u32 = block.height;
        let accepted: bool = false;
        let rejected: bool = false;
        if(current_block_height >= report.block_height + voting_period) 
        {
            if (report.votes_yes > report.votes_no) {
                accepted = true;
            }
            else {
                rejected = true;
            }
        }
        let new_report: Report = Report {
            id: report.id,
            salt: report.salt,
            security_deposit: report.security_deposit,
            block_height: report.block_height,
            content: report.content,
            votes_yes: report.votes_yes + 1u128,
            votes_no: report.votes_no,
            accepted: accepted,
            rejected: rejected,
            solved: report.solved,
            comment: report.comment,
            rewards: report.rewards,
            claimed: report.claimed,
        };
        Mapping::set(reports, id, new_report);
    }
    transition no(
        private id: field,
    ) {
        return then finalize(id);
    }
    finalize no(
        public id: field,
    ) {
        let report: Report = Mapping::get(reports, id);
        assert(report.accepted == false && report.rejected == false);
        // Get the voting period as blocks to be required to ahve passed
        let voting_period: u32 = Mapping::get(settings, 0u8).voting;
        
        // Check if voting has ended, if it has make the decision
        let current_block_height: u32 = block.height;
        let accepted: bool = false;
        let rejected: bool = false;
        if(current_block_height >= report.block_height + voting_period) 
        {
            if (report.votes_yes > report.votes_no) {
                accepted = true;
            }
            else {
                rejected = true;
            }
        }
        let new_report: Report = Report {
            id: report.id,
            salt: report.salt,
            security_deposit: report.security_deposit,
            block_height: report.block_height,
            content: report.content,
            votes_yes: report.votes_yes,
            votes_no: report.votes_no + 1u128,
            accepted: accepted,
            rejected: rejected,
            solved: report.solved,
            comment: report.comment,
            rewards: report.rewards,
            claimed: report.claimed,
        };
        Mapping::set(reports, id, new_report);
    }

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
        assert(report.accepted == true || report.rejected == true);
        let new_report: Report = Report {
            id: report.id,
            salt: report.salt,
            security_deposit: report.security_deposit,
            block_height: report.block_height,
            content: report.content,
            votes_yes: report.votes_yes,
            votes_no: report.votes_no + 1u128,
            accepted: report.accepted,
            rejected: report.rejected,
            solved: solved,
            comment: comment,
            rewards: rewards,
            claimed: report.claimed,
        };
        Mapping::set(reports, id, new_report);
    }

    transition claim(
        private id: field, 
        private salt: field, 
        private amount: u64,
        private sender: user,
        ) -> user {
        // create a proof that this person is the original caller
        // get the salt used originally
        let intermediary_hash: field = BHP256::hash_to_field(self.caller);
        let key_stretching: field = BHP256::hash_to_field((intermediary_hash));
        assert_eq(BHP256::hash_to_field(salt.add(key_stretching)), id);
        let new: user = user {
            owner: self.caller,
            amount: sender.amount + amount,
        };
        //Payout the claimed amount
        return new then finalize(id, amount);
    }
    finalize claim(public id: field, public amount: u64)
    {
        let report: Report = Mapping::get(reports, id);
        assert(report.accepted == true || report.rejected == true);
        assert(report.claimed == false);
        assert(report.security_deposit == amount);
        let new_report: Report = Report {
            id: report.id,
            salt: report.salt,
            security_deposit: report.security_deposit,
            block_height: report.block_height,
            content: report.content,
            votes_yes: report.votes_yes,
            votes_no: report.votes_no,
            accepted: report.accepted,
            rejected: report.rejected,
            solved: report.solved,
            comment: report.comment,
            rewards: report.rewards,
            claimed: true,
        };
        Mapping::set(reports, id, new_report);
    }
}
