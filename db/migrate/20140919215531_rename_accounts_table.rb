#
# Copyright (C) 2014 - present Instructure, Inc.
#
# This file is part of Rollcall.
#
# Rollcall is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Rollcall is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.

class RenameAccountsTable < ActiveRecord::Migration
  def up
    rename_table :accounts, :cached_accounts
    add_column :cached_accounts, :account_id, :integer, :limit => 8
    add_index :cached_accounts, [:account_id, :tool_consumer_instance_guid],
      :name => "index_cached_accounts_on_account_id_and_tciguid"
  end

  def down
    remove_column :cached_accounts, :account_id
    rename_table :cached_accounts, :accounts
  end
end
