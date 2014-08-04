module ChaWork
  class Web < Padrino::Application
    register Padrino::Mailer
    register Padrino::Helpers
    register Padrino::Cookies

    enable :sessions

    before :except => [:login] do
      session[:user_id] = cookies[:user_id].to_s.empty? ? session[:user_id] : cookies[:user_id].to_i
      @user = User.get(session[:user_id])
      if !@user
        redirect 'login'
      end
      @my_projects = UserProject.all(:user_id => @user.id)
    end


    get '/' do 
      render 'index'
      redirect 'bug/tome'
    end

    get :login do 
      cookies[:user_id] = ''
      session[:user_id] = nil
    	render 'login', :layout => false
    end

    post :login do 
        @user = User.authenticate(params[:email], params[:password]) 
        if @user 
           session[:user_id] = @user.id
           response.set_cookie(:user_id, :value => @user.id, :expires => Time.now + 3600*24*7)           
           redirect '/'
        else
           flash.now[:error] = '用户名/密码错误'
           redirect :login
        end
    end

    get :project, :map => 'project/new' do 
      @users     = User.all
      @projects  = Project.all
      render 'project'

    end

    post :project, :map => 'project/create' do 
      params[:end_time] = !params[:end_time].empty? ? params[:end_time] : Time.now()
      project = Project.new(:name        => params[:name],
                            :end_time    => params[:end_time],
                            :description => params[:description],
                            :user_id     => @user.id)
      if project.save && params[:member]
        params[:member].each do |user_id|
          UserProject.first_or_create(:user_id => user_id.to_i, :project_id => project.id )
        end
      end
      redirect '/project/new'
    end

    get :project, :map => 'project/destroy' do 
      project = Project.get(params[:project_id])
      project.destroy if project.user_id == @user.id 
      redirect '/project/new'
    end

    get :project, :map => 'project/modify' do 

      @users     = User.all
      @project   = Project.get(params[:project_id])
      redirect '/project/new' if @project.user_id != @user.id 
      @member    = UserProject.all(:project_id => params[:project_id]).map(&:user_id)
      redirect '/project/new' if @project.nil?
      render 'project_modify'
    end

    post :project, :map => 'project/modify' do 
      params[:end_time] = !params[:end_time].empty? ? params[:end_time] : Time.now()
      project = Project.get(params[:id])
      redirect '/project/new' if project.nil? || project.user_id != @user.id
      project.name        = params[:name]
      project.end_time    = params[:end_time]
      project.description = params[:description]
      UserProject.all(:project_id => params[:id]).destroy
      if project.save && params[:member]
        params[:member].each do |user_id|
          UserProject.first_or_create(:user_id => user_id.to_i, :project_id => project.id )
        end
      end
      redirect "/project/modify?project_id=#{params[:id]}"

    end

    get :project_details do
      @project = Project.get(params[:id])
      @users     = User.all
      render 'project_details' 
    end
    
    #bug 模块
    get :bug, :with => :type do
      params[:type] = 'all' if params[:type].to_s.empty?
      params[:page] = 1     if params[:page].to_s.empty?

      @bugs  = Bug.all
      case params[:type]
      when 'tome'
        @bugs = @bugs.all(:solve_user_id => @user.id)
      when 'byme'
        @bugs = @bugs.all(:user_id => @user.id)
      else

      end
      @bugs = @bugs.all(:status => params[:status]) if !params[:status].to_s.empty?
      @bugs = @bugs.all(:level  => params[:level]) if !params[:level].to_s.empty?
      @bugs_count = @bugs.count
      @bugs = @bugs.all(:order=> :created_at.desc).paginate(:page => params[:page], :per_page => 20)
      render 'bug' 

    end

    get :new_bug do
      @type  = 'new' 
      @users = User.all
      @projects = Project.all
      render 'create_bug' 
    end

    post :new_bug do
      params[:bug][:user_id]= @user.id
      bug = Bug.new(params[:bug])
      bug.save ? flash[:success] = '新建成功' : flash[:error] = '新建失败'
      redirect 'new_bug'
    
    end

    get :modify_bug do 

      @name = 'modify'
      @bug = Bug.get params[:bug_id]
      redirect 'bug/all' if @bug.nil? || @bug.user_id != @user.id
      @type  = 'new' 
      @users = User.all
      @projects = Project.all
      render 'modify_bug' 

    end

    post :modify_bug do 
      @bug = Bug.get params[:bug][:id]
      redirect 'bug/all' if @bug.nil? || @bug.user_id != @user.id
      @bug.title        = params[:bug][:title]
      @bug.project_id   = params[:bug][:project_id]
      @bug.description  = params[:bug][:description]
      @bug.status       = params[:bug][:status]
      @bug.level        = params[:bug][:level]
      @bug.solve_user_id= params[:bug][:solve_user_id]
      @bug.save ? flash[:success] = '修改成功' : flash[:error] = '修改失败'
      redirect "modify_bug?bug_id=#{@bug.id}" 
    end

    post :bug_status do 
      bug = Bug.get params[:bug_id]
      if bug 
        bug.status = params[:status]
        bug.save ? {:status => :success}.to_json : {:status => :success, :msg => '修改失败,请稍候重试'}.to_json
      else
        {:status => :failure, :msg=> '没有找到该条数据，请刷新后重试！'}.to_json
      end
      
    end

    post :bug_description do 
      bug = Bug.get params[:bug_id]
      if bug 
        bug.description = params[:description]
        bug.save ? {:status => :success}.to_json : {:status => :success, :msg => '描述写入失败'}.to_json
      else
        {:status => :failure, :msg=> '没有找到该条数据，请刷新后重试！'}.to_json
      end
    end

    get :destroy_bug do 
      @bug = Bug.get params[:bug_id]
      redirect '/bug/all' if @bug.nil? || @bug.user_id != @user.id
      @bug.destroy
      redirect "/bug/#{params[:module]}?page=#{params[:page].to_s}&status=#{params[:status].to_s}&level=#{params[:level].to_s}" 
    end

    #小结模块
    get :report, :with => :type do
      params[:type] = 'all' if params[:type].to_s.empty?
      params[:page] = 1     if params[:page].to_s.empty?
      @reports  = Report.all
      case params[:type]
      when 'byme'
        @reports = @reports.all(:user_id => @user.id)
      else
      end
      @reports_count = @reports.count
      @reports = @reports.all(:order=> :created_at.desc).paginate(:page => params[:page], :per_page => 20)
      render 'report'
    end

    get :new_report do 
      @type = 'new'
      render 'create_report'

    end

    post :new_report do 
      params[:report][:user_id] = @user.id
      report = Report.new(params[:report])
      report.save ? flash[:success] = '新建成功' : flash[:error] = '新建失败'
      redirect '/report/byme'

    end

    get :modify_report do 
      @type   = 'new'
      @name   = 'modify'
      @report = Report.get params[:report_id]
      redirect 'report/all' if @report.nil? || @report.user_id != @user.id
      @type   = 'new' 
      render 'modify_report' 
    end

    post :modify_report do 
      @report = Report.get params[:report][:id]
      redirect 'report/all' if @report.nil? || @report.user_id != @user.id
      @report.update(params[:report]) 
      # @report.tomorrow = params[:report][:tomorrow]
      # @report.today    = params[:report][:summary]
      @report.save ? flash[:success] = '修改成功' : flash[:error] = '修改失败'
      redirect '/report/byme'
    end

    get :destroy_report do 
      @report = Report.get params[:report_id]
      redirect 'report/all' if @report.nil? || @report.user_id != @user.id
      @report.destroy ? flash[:success] = '删除成功' : flash[:error] = '删除失败'
      redirect "/report/all" 
    end

    # 所有任务
    get :tasks, :map=>'task/all' do
      @users  = User.all
      params[:type] = 'all'
      params[:page] = 1     if params[:page].to_s.empty?
      @tasks = Task.all
      @count = @tasks.count
      @tasks = @tasks.paginate(:page => params[:page], :per_page => 20)
      render "tasks/list"
    end

    # 添加任务
    get :add_task, :map => 'task/add' do
      @type= 'new'
      @task     = Task.new
      @users    = User.all
      @projects = Project.all
      render 'tasks/add'
    end

    # 按周查看
    get :week_task, :map => 'task/week' do

      day  = Date.new
      week = day.wday
      wday = Date.today.wday #今天周几
      week1 = Date.today - wday.days + 1 #周一
      week2 = Date.today - wday.days + 2 #周2
      week3 = Date.today - wday.days + 3 #周3
      week4 = Date.today - wday.days + 4 #周4
      week5 = Date.today - wday.days + 5 #周5
      week6 = Date.today - wday.days + 6 #周6

      @tasks1 = Task.all(:created_at => week1..week2)
      @tasks2 = Task.all(:created_at => week2..week3)
      @tasks3 = Task.all(:created_at => week3..week4)
      @tasks4 = Task.all(:created_at => week4..week5)
      @tasks5 = Task.all(:created_at => week5..week6)

      @type     = 'week'
      @task     = Task.new
      @users    = User.all
      render 'tasks/week'
    end

    #指派给我的任务或者我发布的
    get :task, :with => :type do
      @users  = User.all
      params[:page] = 1     if params[:page].to_s.empty?

      case params[:type]
      when 'byme'
        @add_field = true
        @tasks = Task.all(:user_id=>@user.id)
      when  'tome'
        @tasks = Task.all(:assign=>@user.id)
      else
        @tasks = Task.all
      end
      @count = @tasks.count
      @tasks = @tasks.all(:order => :created_at.desc).paginate(:page => params[:page], :per_page => 20)
      render "tasks/list"
    end

    post :create_task do
      params[:task][:user_id]= @user.id
      task = Task.new(params[:task])
      task.save ? flash[:success] = '添加成功' : flash[:error] = '添加失败'
      user_ids   = User.all.map(&:id)
      user_names = User.all.map(&:name)

      if params[:json]
        return {:id => task.id,
                :user_id => task.user_id,
                :level => task.level, 
                :title => task.title, 
                :user  => task.user.name, 
                :created_at => task.created_at.strftime('%Y/%m/%d'),
                :level_word => task.level_word,
                :stylesheets=> task.stylesheets,
                :assign_id  => task.solve_user.id,
                :assign     => task.solve_user.name,
                :page       => params[:page],
                :user_ids   => user_ids,
                :user_names => user_names}.to_json 
      end
      redirect 'task/add'
    end

    get :modify_task do 
      @name = 'modify'
      @type= 'new'
      @task     = Task.get params[:task_id]
      redirect "/task/tome"  if @task.nil? || @task.user_id != @user.id
      @users    = User.all
      @projects = Project.all

       render 'tasks/modify_task'

    end

    post :modify_task do 
      @task     = Task.get params[:id]

      if !@task.nil? || @task.user_id == @user.id
      @task.update(params[:task])
      flash[:success] = '修改成功' 
      else
      flash[:error] = '修改失败' 
      end
      # @task.save
      redirect "/task/byme"
    end

    get :destroy_task do 
      @task     = Task.get params[:task_id]
      if !@task.nil? || @task.user_id == @user.id
        @task.destroy
        flash[:success] = '删除成功'
      else
        flash[:error] = '删除失败' 
      end
      redirect "/task/byme?page=#{params[:page]}"
    end


    #修改个人资料
    get :account do 
      render 'account'
    end

    post :account do 
      @user.name   = params[:name]
      @user.title  = params[:title]
      @user.photo  = params[:photo] if !params[:photo].to_s.empty?
      @user.save
      render 'account'
    end

    #修改密码
    get :edit_pwd do 
      render 'edit_pwd'
    end

    post :edit_pwd do 
      flash[:error] = '新密码不一致' if params[:confirm_password]!= params[:new_password] || params[:new_password].empty?
      user = User.authenticate(@user.email, params[:password]) 
      if user
        user.crypted_password = 'change'
        user.password = params[:new_password]
        user.save ? (flash[:success] = '密码已修改') : (flash[:error] = '密码修改失败')
      else
        flash[:error] = '密码错误'
      end
      render 'edit_pwd'
    end



  end
end
