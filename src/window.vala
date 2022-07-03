/* window.vala
 *
 * Copyright 2021 Alex
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace DesktopFilesCreator {
	[GtkTemplate (ui = "/com/github/alexkdeveloper/desktop-files-creator/window.ui")]
	public class Window : Adw.ApplicationWindow {
		[GtkChild]
		unowned Gtk.Entry entry_name;
        [GtkChild]
        unowned Gtk.Entry entry_exec;
        [GtkChild]
        unowned Gtk.Entry entry_icon;
        [GtkChild]
        unowned Gtk.Entry entry_categories;
        [GtkChild]
        unowned Gtk.Entry entry_comment;
        [GtkChild]
        unowned Gtk.Switch switch_no_display;
        [GtkChild]
        unowned Gtk.Switch switch_terminal;
        [GtkChild]
        unowned Gtk.Button button_open;
        [GtkChild]
        unowned Gtk.Button button_create;
        [GtkChild]
        unowned Adw.ToastOverlay overlay;

        private string directory_path;

		public Window (Adw.Application app) {
			Object (application: app);
			entry_name.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "edit-clear-symbolic");
			entry_name.icon_press.connect ((pos, event) => {
                entry_name.set_text("");
                entry_name.grab_focus();
            });
            entry_exec.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "document-open-symbolic");
		    entry_exec.icon_press.connect ((pos, event) => {
                on_open_exec();
            });
            entry_icon.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "document-open-symbolic");
			entry_icon.icon_press.connect ((pos, event) => {
			    on_open_icon();
            });
            entry_categories.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "edit-clear-symbolic");
            entry_categories.icon_press.connect ((pos, event) => {
                entry_categories.set_text ("");
                entry_categories.grab_focus();
            });
            entry_comment.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "edit-clear-symbolic");
            entry_comment.icon_press.connect ((pos, event) => {
                entry_comment.set_text ("");
                entry_comment.grab_focus();
            });
            button_open.clicked.connect(on_open_directory);
            button_create.clicked.connect(on_create_file);
	        entry_name.grab_focus();
            directory_path = Environment.get_home_dir()+"/.local/share/applications";
            GLib.File file = GLib.File.new_for_path(directory_path);
            if(!file.query_exists()){
                alert(_("Error!\nPath ")+directory_path+_(" is not exists!\nThe program will not be able to perform its functions."));
                button_create.set_sensitive(false);
                button_open.set_sensitive(false);
            }

            if (Config.DEVELOPMENT) {
                add_css_class ("devel");
            }
		}

		private void on_open_exec(){
            var file_chooser = new Gtk.FileChooserDialog (_("Open File"), this, Gtk.FileChooserAction.OPEN, _("_Cancel"), Gtk.ResponseType.CANCEL, _("_Open"), Gtk.ResponseType.ACCEPT);
            file_chooser.set_modal(true);
            file_chooser.response.connect((response) => {
                if (response == Gtk.ResponseType.ACCEPT) {
                    entry_exec.set_text(file_chooser.get_file().get_path());
                }
                file_chooser.close();
            });

            file_chooser.show();
        }

        private void on_open_icon () {
            var file_chooser = new Gtk.FileChooserDialog (_("Open Image"), this, Gtk.FileChooserAction.OPEN, _("_Cancel"), Gtk.ResponseType.CANCEL, _("_Open"), Gtk.ResponseType.ACCEPT);
            file_chooser.set_modal(true);
            Gtk.FileFilter filter = new Gtk.FileFilter ();
            file_chooser.set_filter (filter);
            filter.add_mime_type ("image/jpeg");
            filter.add_mime_type ("image/png");
            file_chooser.response.connect((response) => {
                if (response == Gtk.ResponseType.ACCEPT) {
                    entry_icon.set_text(file_chooser.get_file().get_path());
                }
                file_chooser.close();
            });

            file_chooser.show();
       }

        private void on_open_directory() {
            Gtk.show_uri(this, "file://"+directory_path, Gdk.CURRENT_TIME);
        }

        private void on_create_file (){
            if(is_empty(entry_name.get_text())){
                set_toast(_("Enter the name"));
                entry_name.grab_focus();
                return;
            }
            GLib.File file = GLib.File.new_for_path(directory_path+"/"+entry_name.get_text().strip()+".desktop");
            if(file.query_exists()){
                alert(_("A file with the same name already exists"));
                entry_name.grab_focus();
                return;
            }
            var dialog_create_desktop_file = new Gtk.MessageDialog(this,Gtk.DialogFlags.MODAL,Gtk.MessageType.QUESTION, Gtk.ButtonsType.OK_CANCEL, _("Create file ")+file.get_basename()+_(" ?"));
            dialog_create_desktop_file.set_title(_("Create"));
            dialog_create_desktop_file.show();
            dialog_create_desktop_file.response.connect((response) => {
                if (response == Gtk.ResponseType.OK) {
                    create_desktop_file();
                }
                dialog_create_desktop_file.close();
            });
        }

        private bool is_empty(string str) {
            return str.strip().length == 0;
        }

        private void create_desktop_file() {
            string display;
            if(switch_no_display.get_active()) {
                display="true";
            } else {
                display="false";
            }
            string terminal;
            if(switch_terminal.get_active()) {
                terminal="true";
            } else {
                terminal="false";
            }
            string desktop_file="[Desktop Entry]
Encoding=UTF-8
Type=Application
NoDisplay="+display+"
Terminal="+terminal+"
Exec="+entry_exec.get_text().strip()+"
Icon="+entry_icon.get_text().strip()+"
Name="+entry_name.get_text().strip()+"
Comment="+entry_comment.get_text().strip()+"
Categories="+entry_categories.get_text().strip();
            string path=directory_path+"/"+entry_name.get_text()+".desktop";
            try {
                FileUtils.set_contents (path, desktop_file);
            } catch (Error e) {
                stderr.printf ("Error: %s\n", e.message);
            }
            GLib.File file = GLib.File.new_for_path(path);
            if(file.query_exists()) {
                alert(_("File ")+file.get_basename()+_(" is created!\nPath: ")+path);
            }else{
                alert(_("Error! Could not create file"));
            }
        }

        private void set_toast (string str){
            var toast = new Adw.Toast (str);
            toast.set_timeout (3);
            overlay.add_toast (toast);
        }

        private void alert (string str){
            var dialog_alert = new Gtk.MessageDialog(this, Gtk.DialogFlags.MODAL, Gtk.MessageType.INFO, Gtk.ButtonsType.OK, str);
            dialog_alert.set_title(_("Message"));
            dialog_alert.response.connect((_) => { dialog_alert.close(); });
            dialog_alert.show();
        }
	}
}
