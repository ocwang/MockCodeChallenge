## Personal notes:

- it's definitely overarchitected per challenge, but wanted to show some level of abstract to detail how I like my projects to look
- conversely, there's some duplicate code that could be cleaned up through abstract
- stuck with your typical MVC instead of MVVM bc I like using RxSwift for observing view models. could thin down the view controllers if you wanted
- unfortunately, challenge didn't provide a working API so I hacked together a mock response that would simulate most of the input/output data when makinng a HTTP request
- a lot of this code could've been condense with 3rd party libaries but as per challenge, used all native frameworks

## iOS Code Challenge

Create a single view iOS application that has a representation of the attached CodeChallengeMockup image:

Requirements:

Use native Apple controls and frameworks only for the user interface.

Note: Authentication is done with a JWT authentication token. Assume you have a valid token.

1. On or before the view is loaded a mock network call will be made to retrieve the profile Information
    The endpoint is "https://api.foo.com/profiles/mine
    JSON return is in the following format:
    ```
    {
        "message": "User Retrieved",
        "data":
        {
            "firstName": "Johnny B",
            "userName": "iOS User",
            "lastName": "Goode"
        }
    }
    ```

2. Both of the "Save Changes" buttons will make a mock network call to the following endpoints:
    Basic Information: POST "https://api.foo.com/profiles/update"
    - required parameters: firstName, lastName
    - successful return will be in the format of:
    ```
    {
        "message": "User Retrieved",
        "data":
        {
            "firstName": "Johnny B",
            "userName": "iOS User",
            "lastName": "Goode"
        }
    }
    
    ```

    Password Change: POST "https://api.foo.com/password/change"
     - required parameters: current password, new password, password confirmation
     - successful return will be in the format of:
     ```
        {
            "data": {},
            "code": "string",
            "message": "Password Changed",
            "exceptionName": null
        }
     ```
    
3. Error handling for the mock returns are required.
