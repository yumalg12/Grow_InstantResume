<%@ page language="java" contentType="text/html; charset=utf-8"%>
<%@ page import="com.instantresume.DAO.UserDAO" %>
<%@ page import="com.instantresume.VO.UserVO" %>
<%@ page import="java.util.List" %>

<!DOCTYPE html>
<html>

<%String userID = (String) session.getAttribute("userID");



String userName = request.getParameter("userName"); 
String userIntroduction = request.getParameter("userIntroduction"); 
String userGitHub = request.getParameter("userGitHub"); 

String profilePic = null;

UserDAO dao = new UserDAO();
List<UserVO> vo = dao.userInfo(userID);

if (vo.size() != 0) {
profilePic = vo.get(0).getProfilePic();
}
%>


<head>
<meta charset="UTF-8">
<title>인스턴트 이력서 생성기</title>
<%@ include file="/view/header.jsp"%>
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta property="og:title" content="<%=userName %> 이력서">
<meta property="og:image" content="./repo/profile/<%=profilePic %>">
<meta property="og:description" content="<%=userName %>의 이력서입니다.">

<link rel="stylesheet" href="./css/frame.css">
<link rel="stylesheet" href="./css/table.css">

<style>
h2 {
   color: #000000;
   padding-top: 1.2rem;
}

div[id="projects"] a{
   text-decoration: none;
}

div[id="projects"] a:hover {
filter: brightness(180%);
}

div[id="projects"] img{
   margin: 0px 0px 5px 5px;
}

</style>

<script>
if ("<%=userGitHub %>" != null && "<%=userGitHub %>" != ""){
$("#gitHubDiv").show();   
}
</script>


<!-- 0710 다운로드할때 외부 css 안깨지게 개선 -->

<script>
async function downloadPage() {
    const styleElements = document.getElementsByTagName("style");
    const linkElements = document.getElementsByTagName("link");

    const concatStyles = (...styles) => styles.join('\n\n');

    const fetchCssFile = async (url) => {
      try {
        const response = await fetch(url, { mode: 'cors', credentials: 'include' });
        const cssText = await response.text();
        return cssText;
      } catch (error) {
        console.error(`Failed to fetch CSS from ${url}`);
        return '';
      }
    };

    const linkPromises = Array.from(linkElements).map(async (link) => {
      const linkUrl = link.href;
      const cssText = await fetchCssFile(linkUrl);
      return cssText;
    });

    const cssLinks = await Promise.all(linkPromises);
    const cssStyles = Array.from(styleElements).map((styleElement) => styleElement.textContent);

    const concatenatedStyles = concatStyles(...cssLinks, ...cssStyles);
    const newStyle = document.createElement("style");
    newStyle.appendChild(document.createTextNode(concatenatedStyles));

    const currentDocumentClone = document.cloneNode(true);
    currentDocumentClone.head.appendChild(newStyle);

    const imageUrlPrefix = "http://localhost:8091";
    const images = currentDocumentClone.querySelectorAll("img");
    for (const img of images) {
        const relativeSrc = img.getAttribute('src');
        const absoluteSrc = new URL(relativeSrc, imageUrlPrefix).toString();
        img.src = absoluteSrc;
    }
    
    const downloadBlob = (content, fileName, mimeType) => {
      const blob = new Blob([content], { type: mimeType });
      const link = document.createElement('a');
      link.href = URL.createObjectURL(blob);
      link.download = fileName;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    };

    const fileName = 'page.html';

    const doctype = new XMLSerializer().serializeToString(
        document.implementation.createDocumentType(
            document.doctype.name,
            document.doctype.publicId,
            document.doctype.systemId
        )
    );

    const markup = doctype + '\n' + currentDocumentClone.documentElement.outerHTML;
    downloadBlob(markup, fileName, 'text/html;charset=utf-8');
}
</script>

</head>


<body>

<div style="text-align: right;">
    <button class="btn btn-line-color2" id="downloadBtn"><img src="/repo/file-earmark-arrow-down.svg" class="small-img">HTML Download</button>
</div>

<script>

<!-- 0710 추가 : downloadBtn 엘리먼트에 클릭 리스너 추가함 -->

const downloadBtn = document.getElementById('downloadBtn');
downloadBtn.addEventListener('click', downloadPage);

</script>
    
    
   <div id="realbody">
      <sidebar>
         <h4 style="padding: 15px 0px 0px 10px">📑목차</h4>
         <hr>
         <ol>
            <li><a href="#about">자기소개</a><br></li>
            <li><a href="#skills">보유 기술</a><br></li>
            <li><a href="#projects">수행 프로젝트</a><br></li>
         </ol>
      </sidebar>

      <div id="contents">

         <!-- About me 시작 -->
         <div id="about">
            <h2>😀‍ About Me</h2>
            <hr>
            <div class="container">
               <aside class="item">
                  <img src="./repo/profile/<%=profilePic %>" style="width: 130px;">
               </aside>
               <section class="item">
                  <label style="font-size: 1.3rem;"><%=userName %></label>
                  <p style="font-size: 0.9rem; color: #aaa; margin-top: 0px;"><%=userID %></p>
                  <p><%=userIntroduction %></p>
                  <div id="gitHubDiv" style="display: none;">
                  <img src="https://img.shields.io/badge/-GitHub-181717?style=for-the-badge&amp;logo=GitHub&amp;logoColor=white" width="120px;" onclick="window.open('<%=userGitHub %>');" style="cursor: pointer;">
                  </div>
               </section>
            </div>
         </div>
         <!-- About me 끝 -->

         <!-- Skills 시작 -->
         <div id="skills">
   <h2>💻 Skills</h2>
   <hr>

   <table>
      <tbody>
         <%
         String[] skillHeaderArray = request.getParameterValues("skillHeader");
         String[] skillListArray = request.getParameterValues("skillList");

         if (skillHeaderArray != null && skillListArray != null) {
            for (int i = 0; i < skillHeaderArray.length; i++) {
         %>
         <tr>
            <td><strong><%= skillHeaderArray[i] %></strong></td>
            <td>
               <%
               String[] split = skillListArray[i].split(",");
               for (int j = 0; j < split.length; j++) {
                  String skill = split[j].trim().toLowerCase();
                  String badgeUrl;
                  switch (skill) {
                     case "html/css":
                        badgeUrl = "https://img.shields.io/badge/-HTML/CSS-1572B6?style=flat&amp;logo=css3&amp;logoColor=white";
                        break;
                     case "html5":
                        badgeUrl = "https://img.shields.io/badge/-HTML5-E34F26?style=flat&amp;logo=html5&amp;logoColor=white";
                        break;
                     case "css3":
                        badgeUrl = "https://img.shields.io/badge/-CSS3-1572B6?style=flat&amp;logo=css3&amp;logoColor=white";
                        break;
                     case "java":
                        badgeUrl = "https://img.shields.io/badge/-JAVA-orange?style=flat&amp;logo=java&amp;logoColor=white";
                        break;
                     case "javascript":
                        badgeUrl = "https://img.shields.io/badge/-JavaScript-F7DF1E?style=flat&amp;logo=JavaScript&amp;logoColor=white";
                        break;
                     case "spring":
                        badgeUrl = "https://img.shields.io/badge/-Spring-6DB33F?style=flat&amp;logo=flat&amp;logoColor=white";
                        break;
                     case "node.js":
                        badgeUrl = "https://img.shields.io/badge/-Node.js-339933?style=flat&amp;logo=nodedotjs&amp;logoColor=white";
                        break;
                     case "react":
                     case "react.js":
                        badgeUrl = "https://img.shields.io/badge/-React-61DAFB?style=flat&amp;logo=react&amp;logoColor=white";
                        break;
                     case "mysql":
                        badgeUrl = "https://img.shields.io/badge/-MySQL-4479A1?style=flat&amp;logo=mysql&amp;logoColor=white";
                        break;
                     case "oracle":
                        badgeUrl = "https://img.shields.io/badge/-Oracle-F80000?style=flat&amp;logo=oracle&amp;logoColor=white";
                        break;
                     case "jquery":
                        badgeUrl = "https://img.shields.io/badge/-jQuery-0769AD?style=flat&amp;logo=jquery&amp;logoColor=white";
                        break;
                     case "bootstrap":
                        badgeUrl = "https://img.shields.io/badge/-Bootstrap-7952B3?style=flat&amp;logo=bootstrap&amp;logoColor=white";
                        break;
                     default:
                        badgeUrl = "https://img.shields.io/badge/-"+skill+"-1D267D?style=flat&amp;logo="+skill+"&amp;logoColor=white";
                  }
                  %>
                  <img src="<%= badgeUrl %>">
                  <%}%>
            </td>
         </tr>
         <%}}%>
      </tbody>
   </table>
</div>
         <!-- Skills 끝 -->
         
         <!-- Projects 시작 -->
         <div id="projects">
      <h2>🗂️ Projects</h2>
      <hr>
      <div class="container gap-5">
         <%
         String[] projectTypeArray = request.getParameterValues("projectType");
         String[] projectNameArray = request.getParameterValues("projectName");
         String[] developerNameArray = request.getParameterValues("developerName");
         String[] contributionArray = request.getParameterValues("contribution");
         String[] startDateArray = request.getParameterValues("startDate");
         String[] finishDateArray = request.getParameterValues("finishDate");
         String[] usedStacksArray = request.getParameterValues("usedStacks");
         String[] projectLinkArray = request.getParameterValues("projectLink");
         String[] projectFeaturesArray = request.getParameterValues("projectFeatures");
         String[] projectEtcArray = request.getParameterValues("projectEtc");

         if (projectTypeArray != null) {
            for (int i = 0; i < projectTypeArray.length; i++) {
         %>
         <div class="item">
            <h4>
               <%
               switch (projectTypeArray[i].toLowerCase()) {
                  case "personal":
                     projectTypeArray[i] = projectTypeArray[i] + "-blue";
                     break;
                  case "team":
                     projectTypeArray[i] = projectTypeArray[i] + "-green";
                     break;
               }
               %>
               <img src="https://img.shields.io/badge/Project-<%=projectTypeArray[i] %>">
               <%=projectNameArray[i] %>
            </h4>
            <table>
               <tbody>
                  <tr>
                     <td><strong>참여자 (기여도)</strong></td>
                     <td><%=developerNameArray[i] %> (<%=contributionArray[i] %>%) 
                     </td>
                  </tr>
                  <tr>
                     <td><strong>기간</strong></td>
                     <td><%=startDateArray[i] %> ~ <%=finishDateArray[i] %></td>
                  </tr>
                  <tr>
                     <td><strong>사용 기술</strong></td>
                     <td><%=usedStacksArray[i] %></td>
                  </tr>
                  <tr>
                     <td><strong>URL</strong></td>
                     <td><a href="<%= projectLinkArray[i] %>"><%= projectLinkArray[i] %></a></td>
                  </tr>
                  <tr>
                     <td><strong>주요 기능</strong></td>
                     <td>
                        <ul>
                           <%
                           String[] split = projectFeaturesArray[i].split("\n");
                           for (int j = 0; j < split.length; j++) {
                              %>
                              <li><%= split[j] %></li>
                              <%}%>
                        </ul>
                     </td>
                  </tr>
                  <tr>
                     <td><strong>비고</strong></td>
                     <td><%=projectEtcArray[i] %></td>
                  </tr>
               </tbody>
            </table>
         </div>
         <%}}%>
      </div>
   </div>
         <!-- Projects 끝 -->
         
      </div>
   </div>
   
<%@include file="/view/footer.jsp" %>
</body></html>
