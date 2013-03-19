class Admin::JobsController < AdminController
  respond_to :html, :json

  def index
    authorize! :index, Delayed::Job
    @jobs = Delayed::Job.accessible_by(current_ability)

    respond_with @jobs
  end

  def show
    @job = Delayed::Job.find(params[:id])
    authorize! :show, @job

    @payload = @job.payload_object

    respond_with @job
  end

end
