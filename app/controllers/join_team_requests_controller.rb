class JoinTeamRequestsController < ApplicationController
	# decide if the controller is accessisable to the user
	before_action :set_event, only => [ :show, :edit, :update, :destroy, :decline]

	def action_allowed?
	  current_role_name.eql?("Student")
	end

	def index
	  @join_team_requests = JoinTeamRequest.all
	  render
	end

	def show
	  render
	end

	def new
	  @join_team_request = JoinTeamRequest.new
	  render
	end

	def edit
	end

	# create a new join team request entry for join_team_request table and add it to the table
	def create
		# check if the advertisement is from a team member and if so disallow requesting invitations
		team_member = TeamsUser.where(['team_id =? and user_id =?', params[:team_id], session[:user][:id]])
		team = Team.find(params[:team_id])
		checkteam_flash(team, team_member)

		if(!team.full? && team_member.empty?)
			@join_team_request = JoinTeamRequest.new
			@join_team_request.comments = params[:comments]
			@join_team_request.status = 'P'
			@join_team_request.team_id = params[:team_id]

			participant = Participant.where(user_id: session[:user][:id], parent_id: params[:assignment_id]).first
			@join_team_request.participant_id = participant.id
			react_for_format
		end
	end

	def react_for_format
		respond_to do |format|
			if @join_team_request.save
				format.html { redirect_to(@join_team_request, notice: 'JoinTeamRequest was successfully created.') }
				format.xml { render xml: @join_team_request, status: :created, location: @join_team_request }
			else
				format.html { render action: "new" }
				format.xml { render xml: @join_team_request.errors, status: :unprocessable_entity }
			end
		end
	end

	def checkteam_flash(team, team_member)
		if team.full?
			flash[:note] = "This team is full."
		elsif !team_member.empty?
			flash[:note] = "You are already a member of this team."
		end
	end


  # update join team request entry for join_team_request table and add it to the table
  def update
	  respond_to do |format|
		  if @join_team_request.update_attribute(:comments, params[:join_team_request][:comments])
			  format.html { redirect_to(@join_team_request, notice: 'JoinTeamRequest was successfully updated.') }
			  format.xml  { head :ok }
		  else
			  format.html { render action: "edit" }
			  format.xml  { render xml: @join_team_request.errors, status: :unprocessable_entity }
		  end
	  end
  end

  def destroy
	  @join_team_request.destroy

	  respond_to do |format|
		  format.html { redirect_to(join_team_requests_url) }
		  format.xml  { head :ok }
	  end
  end

  # decline request to join the team...
  def decline
	  @join_team_request.status = 'D'
	  @join_team_request.save
	  redirect_to view_student_teams_path student_id: params[:teams_user_id]
  end
  private
  def render

	  respond_to do |format|
		  format.html # index.html.erb
		  format.xml  { render xml: @join_team_requests }
	  end
	end
	def set_event
		@join_team_request = JoinTeamRequest.find(params[:id])
	end
end
