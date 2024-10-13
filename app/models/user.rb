class User < ApplicationRecord
  has_many :bookings
  has_many :payments
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :camps, foreign_key: 'user_id'
  has_many :camp_change_requests
  has_many :user_coupons
  has_many :admin_users

  enum role: { user: 0, camp_owner: 1, admin: 2 }

  after_commit :sync_admin_user, if: :saved_changes?
  after_destroy :destroy_admin_user

  def self.ransackable_attributes(auth_object = nil)
      %w[id email name phone created_at updated_at role guest].freeze
  end

         
  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to users_path, notice: 'User created successfully.'
    else
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end


  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_path, notice: 'User deleted successfully.'
  end

  def self.create_guest(name:, email:, phone:)
    create(
      name: name,
      email: email,
      phone: phone,
      password: phone,
      guest: true
    )
  end

  def admin?
    role == 'admin'
  end

  def camp_owner?
    role == 'camp_owner'
  end

  def without_auto_sync
    self.class.skip_callback(:save, :after, :sync_admin_user, raise: false)
    yield
  ensure
    self.class.set_callback(:save, :after, :sync_admin_user, raise: false)
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  


  def sync_admin_user
    admin_user = AdminUser.find_by(user_id: id)
    return unless admin_user

    admin_user.without_auto_sync do
      admin_user.update(
        email: email,
        encrypted_password: encrypted_password,
        reset_password_token: reset_password_token,
        reset_password_sent_at: reset_password_sent_at,
        remember_created_at: remember_created_at,
        role: role,
        guest: guest
      )
    end
  end

  def destroy_admin_user
    admin_user = AdminUser.find_by(user_id: id)
    admin_user.&destroy if admin_user.present?
  end


end
