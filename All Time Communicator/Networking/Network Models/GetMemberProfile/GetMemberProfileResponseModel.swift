//
//  GetMemberProfileResponseModel.swift
//  alltimecommunicator
//
//  Created by Droid5 on 12/09/18.
//  Copyright © 2018 Droid5. All rights reserved.
//

import EVReflection

class GetMemberProfileResponseModel: BaseResponseModel {
    var data: CustomData?

    class CustomData: FindProfileModel {}
}
