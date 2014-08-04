module ChaWork
  class App < Padrino::Application
    register Padrino::Mailer
    register Padrino::Helpers
    register WillPaginate::Sinatra

    enable :sessions

    before :except => [:login] do 
        @user = User.get(session[:user_id]||params[:userid])
    end
    post :login, :provides => [:json] do 
        @user = User.authenticate(params[:email], params[:password]) 
        if @user 
           session[:user_id] = @user.id
           p "====sdfasdf"
            {:status  => :success,
             :name    => @user.name,
             :email   => @user.email,
             :password=> '',
             :id      => @user.id}.to_json
            
        else
            {:status => :failure}.to_json
        end
    end

    get :reports, :with => :type, :provides => [:json] do
      case params[:type]
      when 'byme'
        @reports = Report.all(:user_id => @user.id)
      when 'all'
        @reports = Report.all
      else
        @reports = Report.all(:user_id => params[:type])
      end
        @reports = @reports.all(:order => :created_at.desc).paginate(:page => params[:page], :per_page => 20)
        render 'reports'
      
    end

    #curl http://0.0.0.0:9001/app/reports -d 'userid=3&today=12323232&tomorrow=1211212&summary=1s21212'
    post :reports, :provides => [:json] do 
        @report = Report.first_or_create(:user_id => @user.id, 
                                         :today => params[:today], 
                                         :tomorrow => params[:tomorrow],
                                         :summary => params[:summary])
        @report.wdate = @report.created_at
        
        {:status => @report.save ? :success : :failure}.to_json
    end

    #curl http://0.0.0.0:9001/app/destroy_reports -d 'userid=3&report_id=32'
    #删除
    post :destroy_reports, :provides => [:json] do 
        @report = Report.get params[:report_id]
        return { :status => :failure, :msg => '无权限操作该内容' }.to_json if @report.nil? || @report.user_id != @user.id
        @report.destroy
        {:status => @report ? :success : :failure }.to_json
    end

    #curl http://0.0.0.0:9001/app/modify_reports -d 'userid=3&report_id=30&tomorrow=修改'
    post :modify_reports, :provides => [:json] do 
        @report = Report.get params[:report_id]
        return { :status => :failure, :msg => '无权限操作该内容' }.to_json if @report.nil? || @report.user_id != @user.id
        @report.today    = params[:today]    if params[:today]
        @report.tomorrow = params[:tomorrow] if params[:tomorrow]
        @report.summary  = params[:summary]  if params[:summary]
        {:status => @report.save ? :success : :failure}.to_json
        
    end

    ##
    # You can configure for a specified environment like:
    #
    #   configure :development do
    #     set :foo, :bar
    #     disable :asset_stamp # no asset timestamping for dev
    #   end
    #

    ##
    # You can manage errors like:
    #
    #   error 404 do
    #     render 'errors/404'
    #   end
    #
    #   error 505 do
    #     render 'errors/505'
    #   end
    #

  end
end
