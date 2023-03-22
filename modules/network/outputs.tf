output vpc_id {
  value       = aws_vpc.jenkins_vpc.id
}

output pub_subnet_list {
  value       = [aws_subnet.pub_jenkins_subnet1.id, aws_subnet.pub_jenkins_subnet2.id]
}

output private_subnet_list {
  value       = [aws_subnet.private_jenkins_subnet1.id, aws_subnet.private_jenkins_subnet2.id]
}

output jenkins_cert_arn {
  value       = aws_acm_certificate.jenkins-cert.arn
}

output private_subnet1 {
  value       = aws_subnet.private_jenkins_subnet1.id
}

output private_subnet2 {
  value       = aws_subnet.private_jenkins_subnet2.id
}
