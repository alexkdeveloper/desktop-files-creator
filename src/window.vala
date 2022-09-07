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
		unowned Adw.EntryRow entry_name;
		[GtkChild]
		unowned Gtk.Button clear_name;
        [GtkChild]
        unowned Adw.EntryRow entry_exec;
        [GtkChild]
        unowned Gtk.Button button_exec;
		[GtkChild]
		unowned Gtk.Button clear_exec;
        [GtkChild]
        unowned Adw.EntryRow entry_icon;
        [GtkChild]
        unowned Gtk.Button button_icon;
		[GtkChild]
		unowned Gtk.Button clear_icon;
        [GtkChild]
        unowned Adw.EntryRow entry_categories;
        [GtkChild]
        unowned Gtk.Button clear_categories;
        [GtkChild]
        unowned Adw.EntryRow entry_comment;
        [GtkChild]
        unowned Gtk.Button clear_comment;
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
            entry_name.changed.connect((event) => {
                on_entry_change(entry_name, clear_name);
            });
            clear_name.clicked.connect((event) => {
                on_clear_entry(entry_name);
            });
            button_exec.clicked.connect(on_open_exec);
		    entry_exec.changed.connect((event) => {
                on_entry_change(entry_exec, clear_exec);
            });
            clear_exec.clicked.connect((event) => {
                on_clear_entry(entry_exec);
            });
            button_icon.clicked.connect(on_open_icon);
		    entry_icon.changed.connect((event) => {
                on_entry_change(entry_icon, clear_icon);
            });
            clear_icon.clicked.connect((event) => {
                on_clear_entry(entry_icon);
            });
            entry_categories.changed.connect((event) => {
                on_entry_change(entry_categories, clear_categories);
            });
            clear_categories.clicked.connect((event) => {
                on_clear_entry(entry_categories);
            });
            entry_comment.changed.connect((event) => {
                on_entry_change(entry_comment, clear_comment);
            });
            clear_comment.clicked.connect((event) => {
                on_clear_entry(entry_comment);
            });
            button_open.clicked.connect(on_open_directory);
            button_create.clicked.connect(on_create_file);
            directory_path = Environment.get_home_dir()+"/.local/share/applications";
            GLib.File file = GLib.File.new_for_path(directory_path);
            if(!file.query_exists()){
                alert(_("Error!\nPath: ")+directory_path+_(" does not exist!"), _("The program will not be able to perform its functions."));
                button_create.set_sensitive(false);
                button_open.set_sensitive(false);
            }

            if (Config.DEVELOPMENT) {
                add_css_class ("devel");
            }
		}

        private void on_clear_entry(Adw.EntryRow entry){
            entry.set_text("");
            entry.grab_focus();
        }

        private void on_entry_change(Adw.EntryRow entry, Gtk.Button clear){
            if (!is_empty(entry.get_text())) {
                if (entry == entry_exec) {
                    button_exec.set_visible(false);
                } else if (entry == entry_icon) {
                    button_icon.set_visible(false);
                }
                clear.set_visible(true);
            } else {
                if (entry == entry_exec) {
                    button_exec.set_visible(true);
                } else if (entry == entry_icon) {
                    button_icon.set_visible(true);
                }
                clear.set_visible(false);
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
            filter.add_mime_type ("image/svg+xml");
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
                alert(_("A file with the same name already exists"), "");
                entry_name.grab_focus();
                return;
            }
            var dialog_create_desktop_file = new Adw.MessageDialog(this, _("Create file ")+file.get_basename()+"?", "");
            dialog_create_desktop_file.add_response("cancel", _("_Cancel"));
            dialog_create_desktop_file.add_response("ok", _("_OK"));
            dialog_create_desktop_file.set_default_response("ok");
            dialog_create_desktop_file.set_close_response("cancel");
            dialog_create_desktop_file.set_response_appearance("ok", SUGGESTED);
            dialog_create_desktop_file.show();
            dialog_create_desktop_file.response.connect((response) => {
                if (response == "ok") {
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
                alert(_("File ")+file.get_basename()+(_(" is created!")), _("Path: ")+path);
            }else{
                alert(_("Error! Could not create file"), "");
            }
        }

        private void set_toast (string str){
            var toast = new Adw.Toast (str);
            toast.set_timeout (3);
            overlay.add_toast (toast);
        }

        private void alert (string heading, string body){
            var dialog_alert = new Adw.MessageDialog(this, heading, body);
            if (body != "") {
                dialog_alert.set_body(body);
            }
            dialog_alert.add_response("ok", _("_OK"));
            dialog_alert.set_response_appearance("ok", SUGGESTED);
            dialog_alert.response.connect((_) => { dialog_alert.close(); });
            dialog_alert.show();
        }
	}
}
