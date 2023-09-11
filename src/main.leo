// The 'guarded_feedback' program.
program guarded_feedback.aleo {

    struct Report {
        id: field,
        block_height: u32,
        content: field,
        vote_yes: u128,
        vote_no: u128,
        rejected: bool,
        solved: bool,
        comment: field,
        rewards: u64,
    }

    mapping reports: field => Report;

    // This stores the salt for every id
    mapping salts: field => field;

    record user {
        owner: address,
        microcredits: u64
    }

    // The transition is most likely run on the clients computer
    // Key Stretching and a random salt will be used to resist hashmaps and collisions, aswell as brute forcing
    transition submit_report(
        public content: field,
        public security_deposit: u64,
        private random_salt: field,
    ) -> user {
        let new: user = user {
            owner: self.caller,
            microcredits: security_deposit
        };
        let intermediary_hash: field = BHP256::hash_to_field(self.caller);
        let key_stretching: field = BHP256::hash_to_field((intermediary_hash));
        let id: field = BHP256::hash_to_field(random_salt.add(key_stretching));
        return new then finalize(content, security_deposit, id, random_salt);
    }
    finalize submit_report(public content: field,
    public security_depost: u64,
    public id: field,
    public random_salt: field,)
    {
        // store the random salt
        Mapping::set(salts, id, random_salt);
        // create the user struct and map it to the id
        Mapping::set(reports, id, Report {
            id: id,
            block_height: block.height,
            content: content,
            vote_yes: 0u128,
            vote_no: 0u128,
            rejected: false,
            solved: false,
            comment: 0field,
            rewards: 0u64,
        });
    }

    transition vote_yes(
        private id: field,
    ) {
        return then finalize(id);
    }
    finalize vote_yes(
        public id: field,
    ) {
        let report: Report = Mapping::get(reports, id);
        let new_report: Report = Report {
            id: report.id,
            block_height: report.block_height,
            content: report.content,
            vote_yes: report.vote_yes + 1u128,
            vote_no: report.vote_no,
            rejected: report.rejected,
            solved: report.solved,
            comment: report.comment,
            rewards: report.rewards,
        };
    }
    transition vote_no(
        private id: field,
    ) {
        return then finalize(id);
    }
    finalize vote_no(
        public id: field,
    ) {
        let report: Report = Mapping::get(reports, id);
        let new_report: Report = Report {
            id: report.id,
            block_height: report.block_height,
            content: report.content,
            vote_yes: report.vote_yes,
            vote_no: report.vote_no + 1u128,
            rejected: report.rejected,
            solved: report.solved,
            comment: report.comment,
            rewards: report.rewards,
        };
    }
}
