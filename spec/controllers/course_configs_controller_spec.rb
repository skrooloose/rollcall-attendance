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

require 'spec_helper'

describe CourseConfigsController do
  let(:section) { Section.new(id: 1, students: [{id: 1}]) }
  let(:sections) { [section] }
  let(:user_id) { 5 }
  let(:tci_guid) { 'abc123' }

  before do
    allow(controller).to receive(:require_lti_launch)
    allow(controller).to receive(:request_canvas_authentication)
    allow(controller).to receive(:load_and_authorize_sections) { sections }
    allow(controller).to receive(:resubmit_all_grades!)
    allow(controller).to receive(:authorized_to_update_config?).and_return(true)
    allow(controller).to receive(:user_id).and_return(user_id)
    allow(controller).to receive(:can_grade)
    session[:tool_consumer_instance_guid] = tci_guid
  end

  describe "update" do
    let(:cc) {
      CourseConfig.new(course_id: 3, tool_consumer_instance_guid: tci_guid)
    }

    before do
      allow(CourseConfig).to receive(:find_by) { cc }
    end

    it "updates grades and saves when the tardy weight changes" do
      expect(controller).to receive(:resubmit_all_grades!).with(cc)
      put :update, id: 1, course_config: { tardy_weight: 0.63 }, format: :json
    end

    it "just saves when the tardy weight is blank" do
      expect(controller).not_to receive(:resubmit_all_grades!)
      put :update, id: 1, course_config: {}, format: :json
    end
  end

  describe "resubmit_all_grades!" do
    before { allow(controller).to receive(:resubmit_all_grades!).and_call_original }

    it "queues up an all grade update" do
      expect(Resque).to receive(:enqueue).with(AllGradeUpdater, kind_of(Hash))
      controller.send(:resubmit_all_grades!, CourseConfig.new(course_id: 3))
    end
  end
end
