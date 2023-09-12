// The 'guarded_feedback' program.
program guarded_feedback.aleo {

    struct Report {
        id: field,
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

    mapping reports: field => Report;

    // This stores the salt for every id
    mapping salts: field => field;

    // This stores the count of all reports submitted
    mapping counter: u8 => u128;

    // This stores settings, such as the voting period
    mapping settings: u8 => u32;

    record user {
        owner: address,
        amount: u64,
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
        // update the counter
        let current_counter: u128 = Mapping::get_or_use(counter, 0u8, 0u128);
        Mapping::set(counter, 0u8, current_counter + 1u128);
        // store the random salt
        Mapping::set(salts, id, random_salt);
        // create the user struct and map it to the id
        Mapping::set(reports, id, Report {
            id: id,
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
        let voting_period: u32 = Mapping::get_or_use(settings, 0u8, 0u32);
        
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
        let voting_period: u32 = Mapping::get_or_use(settings, 0u8, 0u32);
        
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
        return then finalize(id, comment, rewards, solved);
    }
    finalize respond(
        public id: field,
        public comment: field,
        public rewards: u64,
        public solved: bool,
    )
    {
        let report: Report = Mapping::get(reports, id);
        assert(report.accepted == true || report.rejected == true);
        let new_report: Report = Report {
            id: report.id,
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
