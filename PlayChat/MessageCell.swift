/**
 # Copyright Google Inc. 2016
 # Licensed under the Apache License, Version 2.0 (the "License");
 # you may not use this file except in compliance with the License.
 # You may obtain a copy of the License at
 #
 # http://www.apache.org/licenses/LICENSE-2.0
 #
 # Unless required by applicable law or agreed to in writing, software
 # distributed under the License is distributed on an "AS IS" BASIS,
 # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 # See the License for the specific language governing permissions and
 # limitations under the License.
 **/

class MessageCell: UITableViewCell {
    let padding: CGFloat = 5
    var body: UILabel!
    var details: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        body = UILabel(frame: CGRect.zero)
        body.font = UIFont.systemFont(ofSize: 18)
        body.textAlignment = .left
        body.textColor = UIColor.black
        contentView.addSubview(body)
        
        details = UILabel(frame: CGRect.zero)
        details.textAlignment = .right
        details.font = UIFont.systemFont(ofSize: 11)
        details.textColor = UIColor.darkGray
        contentView.addSubview(details)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        body.frame = CGRect(x: padding, y: padding, width: frame.width - padding * 2, height: frame.height - 6 * padding)
        details.frame = CGRect(x: padding, y: frame.height - 6 * padding, width: frame.width - padding * 2, height: 6 * padding)
    }
}
