package net.elephantbase.users.web;

import net.elephantbase.users.biz.Users;
import net.elephantbase.util.Smtp;
import net.elephantbase.util.wicket.CaptchaPanel;

import org.apache.wicket.markup.html.form.Form;
import org.apache.wicket.markup.html.form.RequiredTextField;
import org.apache.wicket.model.Model;

public class GetPasswordPanel extends BasePanel {
	private static final long serialVersionUID = 1L;

	CaptchaPanel pnlCaptcha = new CaptchaPanel("pnlCaptcha");

	public GetPasswordPanel() {
		super("找回密码", UsersPage.SUFFIX, NO_AUTH);

		final RequiredTextField<String> txtUsername = new
				RequiredTextField<String>("txtUsername", Model.of(""));
		final RequiredTextField<String> txtEmail = new
				RequiredTextField<String>("txtEmail", Model.of("@"));

		Form<Void> frm = new Form<Void>("frm") {
			private static final long serialVersionUID = 1L;

			@Override
			protected void onSubmit() {
				if (!pnlCaptcha.validate()) {
					setWarn("验证码错误");
					return;
				}
				String username = txtUsername.getModelObject();
				String email = txtEmail.getModelObject();
				if (!email.equals(Users.getEmail(username))) {
					setWarn("用户名与Email不匹配");
					return;
				}
				String password = Users.getSalt();
				StringBuilder sb = new StringBuilder();
				sb.append(username + "，您好！\r\n\r\n");
				sb.append("　　您的密码已被重置为：" + password + "\r\n");
				sb.append("　　请用此密码登录到象棋巫师用户中心：\r\n");
				sb.append("　　　　http://www.elephantbase.net:8080/users/\r\n");
				sb.append("　　登录成功后请马上把密码改掉。\r\n\r\n");
				sb.append("　　感谢您使用象棋巫师。\r\n\r\n");
				sb.append("象棋巫师用户中心");
				if (Smtp.send(email, username + "的密码已被重置", sb.toString())) {
					Users.updateInfo(username, email, password);
					setResponsePanel(new GetPasswordPanel2());
				} else {
					setWarn("发送Email失败，请稍候再试");
				}
			}
		};
		frm.add(txtUsername, txtEmail, pnlCaptcha);
		add(frm);
	}
}