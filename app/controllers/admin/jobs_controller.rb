class Admin::JobsController < AdminController
  respond_to :html, :json

  def index
    @jobs = Delayed::Job.scoped
    respond_with @jobs
  end

  def show
    @job = Delayed::Job.find(params[:id])
    @payload = @job.payload_object
    respond_with @job
  end

end
