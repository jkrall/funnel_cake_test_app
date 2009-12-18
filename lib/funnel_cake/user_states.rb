module FunnelCake::UserStates
  def initialize_states

    funnel_state :page_visited, :primary=>true
    funnel_state :ccproc_report

    funnel_state :auction_form_visited, :primary=>true
    funnel_state :signup_step_2, :primary=>true
    funnel_state :signup_step_3
    funnel_state :signup_step_3_previous_statement
    funnel_state :signup_step_4

    funnel_state :auction_started, :primary=>true
    funnel_state :auction_closed, :primary=>true
    funnel_state :auction_bid_selected, :primary=>true
    funnel_state :auction_completed
    funnel_state :auction_booked, :primary=>true

		funnel_state :auction_statement_emailed, :hidden=>true
		funnel_state :auction_uploaded_statement
		funnel_state :savings_analysis_ready

    funnel_event :view_page do
      transitions :unknown,                     :page_visited
      transitions :page_visited,                :page_visited
    end
    funnel_event :create_ccproc_report do
      transitions :page_visited,                :ccproc_report
    end

    funnel_event :auction_form_visit do
      transitions :page_visited,                :auction_form_visited
      transitions :ccproc_report,               :auction_form_visited
    end
    funnel_event :signup_step_2 do
      transitions :auction_form_visited,        :signup_step_2
    end
    funnel_event :signup_step_3 do
      transitions :signup_step_2,               :signup_step_3
    end
    funnel_event :signup_step_3_previous_statement do
      transitions :signup_step_3,               :signup_step_3_previous_statement
    end
    funnel_event :signup_step_4 do
      transitions :signup_step_3_previous_statement,          :signup_step_4
      transitions :signup_step_3,               :signup_step_4
    end

    funnel_event :start_auction do
      transitions :signup_step_4,               :auction_started
    end

    funnel_event :close_auction do
      transitions :auction_started,             :auction_closed
      transitions :auction_statement_emailed,   :auction_closed
    end
    funnel_event :auction_choosebid_email do
      transitions :auction_closed,              :auction_choosebid_emailed
    end
    funnel_event :upload_statement do
      transitions :auction_closed,              :auction_uploaded_statement
      transitions :auction_choosebid_emailed,   :auction_uploaded_statement
    end
    funnel_event :savings_analysis_ready_email do
      transitions :auction_uploaded_statement,  :savings_analysis_ready
    end
    funnel_event :select_bid do
      transitions :auction_closed,              :auction_bid_selected
      transitions :auction_statement_emailed,   :auction_bid_selected
      transitions :auction_choosebid_emailed,   :auction_bid_selected
      transitions :auction_uploaded_statement,  :auction_bid_selected
      transitions :savings_analysis_ready,      :auction_bid_selected
    end

    funnel_event :auction_finish_email do
      transitions :auction_bid_selected,        :auction_finish_emailed
    end
    funnel_event :complete_auction do
      transitions :auction_bid_selected,        :auction_completed
      transitions :auction_finish_emailed,      :auction_completed
    end
    funnel_event :book_auction do
      transitions :auction_finish_emailed,        :auction_booked
      transitions :auction_bid_selected,        :auction_booked
      transitions :auction_completed,           :auction_booked
    end

  end
end
