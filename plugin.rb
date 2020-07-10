# name: omniauth-mindvalley-discourse
# about: Authenticate with discourse with Mindvalley
# version: 0.1.0
# author: parasquid

gem 'handcash-connect-auth'


class HandCashConnectAuthenticator < ::Auth::Authenticator

  def name
    'handcash-connect'
  end

  def after_authenticate(data)
    result = Auth::Result.new

    # grap the info we need from omni auth
    authToken = data['authToken']
    signingToken = data['signingToken']

    # plugin specific data storage
    current_info = ::PluginStore.get("mv", "mv_uid_#{mv_uid}")

    result.user =
      if current_info
        User.where(id: current_info[:user_id]).first
      end

    result.authToken = authToken
    result.signingToken = signingToken

    result
  end

  def after_create_account(user, auth)
    data = auth[:extra_data]
    ::PluginStore.set("mv", "mv_uid_#{data[:mv_uid]}", {user_id: user.id })
  end

  def register_middleware(omniauth)
    handcash.provider :handcash,
  end
end


auth_provider :title => 'with HandCash Accounts',
    :message => 'Log in via HandCash',
    :frame_width => 920,
    :frame_height => 800,
    :authenticator => MindvalleyAuthenticator.new


# We ship with zocial, it may have an icon you like http://zocial.smcllns.com/sample.html
#  in our current case we have an icon for vk
register_css <<CSS

.btn-social.vkontakte {
  background: #46698f;
}

.btn-social.vkontakte:before {
  content: "N";
}

CSS
